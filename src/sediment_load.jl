#    Copyright (C) 2022  Daisuke Nakahara

#    This file is part of FigureGeneration

#    FigureGeneration is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    FigureGeneration is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

module SedimentLoad

using
    Printf,
    Plots,
    Statistics,
    DataFrames,
    StatsPlots,
    CSV,
    LinearAlgebra,
    ..GeneralGraphModule

import
    ..Main_df,
    ..Each_year_timing


include("./sub_sediment_load/sediment_load_each_year.jl")

export
    make_graph_suspended_volume_flow_dist,
    make_graph_bedload_volume_flow_dist,
    make_graph_sediment_volume_flow_dist,
    make_graph_suspended_load_target_hour,
    make_graph_bedload_target_hour,
    make_graph_suspended_bedload_target_hour,
    plot_yearly_mean_suspended_load,
    plot_yearly_mean_bedload,
    plot_particle_yearly_mean_suspended,
    plot_particle_yearly_mean_bedload,
    plot_percentage_particle_yearly_mean_suspended,
    plot_percentage_particle_yearly_mean_bedload,
    plot_time_series_suspended,
    plot_time_series_bedload,
    plot_time_series_variation_suspended,
    plot_time_series_variation_bedload,
    make_graph_time_series_particle_suspended_load,
    make_graph_time_series_particle_bedload,
    make_graph_time_series_particle_suspended_bedload,
    make_graph_time_series_percentage_particle_suspended_load,
    make_graph_time_series_percentage_particle_bedload,
    make_graph_time_series_amount_percentage_particle_suspended_load,
    make_graph_time_series_amount_percentage_particle_bedload,
    plot_condition_change_particle_yearly_mean_suspended_load,
    plot_condition_rate_yearly_mean_suspended_load,
    plot_condition_rate_particle_yearly_mean_suspended_load,
    make_graph_condition_change_yearly_mean_bedload,
    plot_condition_rate_yearly_mean_bedload,
    plot_condition_rate_particle_yearly_mean_bedload,
    make_graph_yearly_mean_suspended_load_per_case,
    make_graph_yearly_mean_bed_load_per_case,
    make_figure_yearly_mean_particle_suspended_sediment_load_stacked,
    make_figure_yearly_mean_particle_bedload_sediment_load_stacked,
    make_suspended_sediment_per_year_csv,
    make_bedload_sediment_per_year_csv,
    make_suspended_sediment_mean_year_csv,
    make_bedload_sediment_mean_year_csv,
    # sediment_load_each_year.jl
    make_graph_particle_suspended_volume_each_year,
    make_graph_particle_suspended_volume_each_year_with_average_line,
    make_graph_condition_change_suspended_volume_each_year,
    make_graph_condition_change_suspended_volume_each_year_with_average_line,
    make_graph_particle_bedload_volume_each_year,
    make_graph_particle_bedload_volume_each_year_with_average_line,
    make_graph_condition_change_bedload_volume_each_year,
    make_graph_condition_change_bedload_volume_each_year_with_average_line


#特定位置の各年の年間掃流砂量の配列を出力する関数
function bedload_sediment_volume_each_year!(
    sediment::AbstractArray{<:AbstractFloat, 1},
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int
    )

    sediment_volume_each_year!(
        sediment,
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        :Qball,
        start_year,
        final_year
    )

    return sediment

end


function bedload_sediment_volume_each_year(
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int
    )

    sediment = sediment_volume_each_year(
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        :Qball,
        start_year,
        final_year
    )

    return sediment

end


#特定位置の各年の年間浮遊砂量の配列を出力する関数
function suspended_sediment_volume_each_year!(
    sediment::AbstractArray{<:AbstractFloat, 1},
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int
    )

    sediment_volume_each_year!(
        sediment,
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        :Qsall,
        start_year,
        final_year
    )

    return sediment

end


function suspended_sediment_volume_each_year(
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int
    )

    sediment = sediment_volume_each_year(
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        :Qsall,
        start_year,
        final_year
    )

    return sediment

end

"""
特定位置の各年の年間の任意の粒径階、任意の土砂の種類の流砂量の配列を出力する
"""
function sediment_volume_each_year!(
    sediment::AbstractArray{<:AbstractFloat, 1},
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    target_symbol::Symbol,
    start_year::Int,
    final_year::Int
    )

    for (i, year) in enumerate(start_year:final_year)
        if haskey(each_year_timing.dict, year) == true
            for hour in each_year_timing.dict[year][1]:each_year_timing.dict[year][2]

                (start_i, final_i) =
                    GeneralGraphModule.decide_index_number(
                        hour,
                        num_data_flow
                    )

                sediment[i] +=
                    data_file[start_i:final_i, target_symbol][area_index]

            end
        end
    end

    return sediment
    
end

function sediment_volume_each_year(
    area_index::Int,
    num_data_flow::Int,    
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    target_symbol::Symbol,
    start_year::Int,
    final_year::Int
    )

    sediment = zeros(Float64,final_year-start_year+1)
    
    sediment_volume_each_year!(
        sediment,
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        target_symbol,
        start_year,
        final_year
    )

    return sediment
    
end

#全粒径階の流砂量を取り出す
"""
ある位置の全ての粒度階別の各年の浮遊砂量の配列を作成する
"""
function particle_suspended_sediment_volume_each_year(
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int,
    sediment_size::DataFrame
    )

    sediment = particle_sediment_volume_each_year(
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        start_year,
        final_year,
        sediment_size,
        :Qsall
    )


    return sediment
    
end

"""
ある位置の全ての粒度階別の各年の掃流砂量の配列を作成する
"""
function particle_bedload_sediment_volume_each_year(
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int,
    sediment_size::DataFrame
    )

    sediment = particle_sediment_volume_each_year(
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        start_year,
        final_year,
        sediment_size,
        :Qball
    )
    
    return sediment
    
end

function particle_sediment_volume_each_year!(
    sediment::AbstractArray{<:AbstractFloat, 2},
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int,
    target_symbol::Symbol
    )

    @views for particle_class_num in 1:size(sediment, 2)
        sediment_sub = sediment[:, particle_class_num]
        sediment_volume_each_year!(
            sediment_sub,
            area_index,
            num_data_flow,
            data_file,
            each_year_timing,
            Symbol(string(target_symbol, Printf.@sprintf("%02i", particle_class_num))),
            start_year,
            final_year
        )
    end

    return sediment
    
end

function particle_sediment_volume_each_year(
    area_index::Int,
    num_data_flow::Int,
    data_file::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int,
    sediment_size::DataFrame,
    target_symbol::Symbol
    )

    sediment_size_num = size(sediment_size, 1)

    sediment = zeros(Float64, final_year-start_year+1, sediment_size_num)

    particle_sediment_volume_each_year!(
        sediment,
        area_index,
        num_data_flow,
        data_file,
        each_year_timing,
        start_year,
        final_year,
        target_symbol
    )
    
    return sediment
    
end

#年平均関連

function core_yearly_mean_sediment_load_whole_area!(
    sediment_load_yearly_mean,
    flow_size::Int,
    df::DataFrame,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    tag::Symbol
    )

    for target_year in start_year:final_year

        sediment_load_each_year   = zeros(Float64, flow_size)
        sediment_load_whole_area_each_year!(sediment_load_each_year,df,target_year,each_year_timing,tag)

        sediment_load_yearly_mean .= sediment_load_yearly_mean .+ sediment_load_each_year

    end

    sediment_load_yearly_mean .= sediment_load_yearly_mean ./(final_year-start_year+1)

    return sediment_load_yearly_mean

end

#年平均土砂量を表示できるようにプログラムを変更する。
#過去のJupyter-labのコードを参考にする。
function sediment_load_whole_area(df, target_hour::Int, tag::Symbol)

    start_index, final_index = decide_index_number(target_hour)

    return df[start_index:final_index, tag]

end

function sediment_load_whole_area_each_year!(
    sediment_load_each_year,
    df::DataFrame,
    target_year::Int,
    each_year_timing::Each_year_timing,
    tag::Symbol
    )

    for target_hour in each_year_timing.dict[target_year][1]:each_year_timing.dict[target_year][2]

        start_index,final_index=decide_index_number(target_hour)

        sediment_load_each_year .= sediment_load_each_year .+ df[start_index:final_index, tag]

    end

    return sediment_load_each_year
end


function sediment_load_whole_area_each_year(
    df, target_year::Int, each_year_timing::Each_year_timing, tag::Symbol
    )

    flow_size = length(df[df.T .== 0, :I])
    sediment_load_each_year = zeros(Float64, flow_size)
    sediment_load_whole_area_each_year!(
        sediment_load_each_year, df, target_year,
	each_year_timing,tag
    )

    return sediment_load_each_year
end

function yearly_mean_sediment_load_whole_area!(
    sediment_load_yearly_mean, flow_size::Int,
    df, start_year::Int, final_year::Int,
    each_year_timing::Each_year_timing, tag::Symbol)

    for target_year in start_year:final_year
        sediment_load_each_year = zeros(Float64, flow_size)
	
        sediment_load_whole_area_each_year!(
	    sediment_load_each_year,
            df,
            target_year,
	    each_year_timing,
            tag
        )

        sediment_load_yearly_mean .= sediment_load_yearly_mean .+ sediment_load_each_year

    end

    sediment_load_yearly_mean .= sediment_load_yearly_mean ./ (final_year - start_year + 1)

    return sediment_load_yearly_mean
end

function yearly_mean_sediment_load_whole_area(
    df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    tag::Symbol
    )

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean,
        flow_size,
	df,
        start_year,
        final_year,
        each_year_timing,
	tag
    )

    return sediment_load_yearly_mean
end


function make_graph_suspended_volume_flow_dist(
    df::DataFrame,
    target_year::Int,
    each_year_timing::Each_year_timing)

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_each_year = zeros(Float64, flow_size)
    
    sediment_load_whole_area_each_year!(
        sediment_load_each_year, df, target_year,
	each_year_timing,:Qsall
    )

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
          reverse(sediment_load_each_year),
	  title=string(target_year),
	  label="",
	  xlabel="Distance from the estuary (km)",
          ylabel="Yearly Suspended\n Sediment Load (m³/year)",
	  xlims=(0,77.8))
end

function make_graph_bedload_volume_flow_dist(
    df::DataFrame,
    target_year::Int,
    each_year_timing::Each_year_timing)

    flow_size = length(df[df.T .== 0, :I])
    sediment_load_each_year = zeros(Float64, flow_size)
    
    sediment_load_whole_area_each_year!(
        sediment_load_each_year, df, target_year,
	each_year_timing,:Qball
    )

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
          reverse(sediment_load_each_year),
	  title=string(target_year),
	  label="",
	  xlabel="Distance from the estuary (km)",
          ylabel="Yearly \n Bedload (m³/year)",
	  xlims=(0,77.8))
end

function make_graph_sediment_volume_flow_dist(
    data_file::DataFrame,
    target_year::Int,
    each_year_timing::Each_year_timing
    )

    p1 = make_graph_suspended_volume_flow_dist(
        data_file,target_year,each_year_timing
    )

    plot!(
        p1, xlabel="", ylabel="Yearly\n Suspended\n Load\n (m³/year)",
        ylims=(0, 1.4e7)
    )

    p2 = make_graph_bedload_volume_flow_dist(
        data_file,target_year,each_year_timing
    )

    plot!(
        p2, title="", ylabel="Yearly\n Bedload\n (m³/year)",
        ylims=(0, 2.0e5)
    )

    l = @layout[a; b]

    plot(p1, p2, layout=l)

end

function _core_make_graph_suspended_load_target_hour(
    target_hour::Int,
    time_schedule::DataFrames.DataFrame;
    japanese::Bool=false
    )

    target_second = 3600 * target_hour
    
    start_index, finish_index = decide_index_number(target_hour)

    if japanese == true
        
        want_title = making_time_series_title(
            "浮遊砂量",
            target_hour,
            target_second,
            time_schedule
	)

        yl = "浮遊砂量 (m³/s)"

        xl = "河口からの距離 (km)"

    else

        want_title = making_time_series_title(
            "Suspended",
            target_hour,
            target_second,
            time_schedule
	)

        yl = "Suspended load (m³/s)"

        xl = "Distance from the estuary (km)"
        
    end

    return target_second,
    start_index,
    finish_index,
    want_title,
    yl,
    xl

end

function _core_make_graph_bedload_target_hour(
    target_hour::Int,
    time_schedule::DataFrames.DataFrame;
    japanese::Bool=false
    )

    target_second = 3600 * target_hour
    
    start_index, finish_index = decide_index_number(target_hour)

    if japanese == true
        
        want_title = making_time_series_title(
            "掃流砂量",
            target_hour,
            target_second,
            time_schedule
	)

        yl = "掃流砂量 (m³/s)"

        xl = "河口からの距離 (km)"
        
    else

        want_title = making_time_series_title(
            "Bedload",
            target_hour,
            target_second,
            time_schedule
	)

        yl = "Bedload (m³/s)"

        xl = "Distance from the estuary (km)"

    end

    return target_second,
    start_index,
    finish_index,
    want_title,
    yl,
    xl

end


"""
特定の時間における合計の浮遊砂量の縦断分布のグラフを作る。
"""
function make_graph_suspended_load_target_hour(
    main_df::Main_df,
    target_hour::Int,
    time_schedule::DataFrames.DataFrame;
    target_df::Int=1,
    japanese::Bool=false
    )

    target_second,
    start_index,
    finish_index,
    want_title,
    yl,
    xl = _core_make_graph_suspended_load_target_hour(
        target_hour,
        time_schedule;
        japanese=japanese
    )

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    plot!(main_df.tuple[target_df][main_df.tuple[target_df].T .== 0, :I].*10^-3,
          reverse(main_df.tuple[target_df][start_index:finish_index,:Qs]),
          label="", fillrange=0,
          ylabel=yl, xlims=(0,77.8),ylims=(0,100),
	  title=want_title, xlabel=xl,
	  xticks=[0, 20, 40, 60, 77.8],
	  linewidth=2, legend=:topleft,
	  color=:firebrick)
    
end

"""
特定の時間における合計の掃流砂量の縦断分布のグラフを作る。
"""
function make_graph_bedload_target_hour(
    main_df::Main_df,
    target_hour::Int,
    time_schedule::DataFrames.DataFrame;
    target_df::Int=1,
    japanese::Bool=false
    )

    target_second,
    start_index,
    finish_index,
    want_title,
    yl,
    xl = _core_make_graph_bedload_target_hour(
        target_hour,
        time_schedule;
        japanese=japanese
    )
    
    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    plot!(main_df.tuple[target_df][main_df.tuple[target_df].T .== 0, :I].*10^-3,
          reverse(main_df.tuple[target_df][start_index:finish_index,:Qb]),
          label="", fillrange=0,
          ylabel=yl, xlims=(0,77.8),ylims=(0,2),
	  title=want_title, xlabel=xl,
	  xticks=[0, 20, 40, 60, 77.8],
	  linewidth=2, legend=:topleft,
	  color=:royalblue)
    
end

"""
特定の時間における合計の浮遊砂量（上図）と掃流砂量（下図）の縦断分布のグラフを作る。
"""
function make_graph_suspended_bedload_target_hour(
    main_df::Main_df,
    target_hour::Int,
    time_schedule::DataFrames.DataFrame;
    target_df::Int=1,
    japanese::Bool=false
    )

    l = @layout[a; b]

    p1 = make_graph_suspended_load_target_hour(
        data_file,
        target_hour,
        time_schedule,
        target_df=target_df,
        japanese=japanese
    )
    
    plot!(p1, xlabel="")

    p2 = make_graph_bedload_target_hour(
        data_file,
        target_hour,
        time_schedule,
        target_df=target_df,
        japanese=japanese
    )

    plot(p1, p2, layout=l)
end

"""
特定の時間における粒径階別の浮遊砂量の縦断分布のグラフを作る。
"""
function make_graph_suspended_load_target_hour(
    main_df::Main_df,
    target_hour::Int,
    time_schedule::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame;
    target_df::Int=1,
    japanese::Bool=false
    )

    target_second,
    start_index,
    finish_index,
    want_title,
    yl,
    xl = _core_make_graph_suspended_load_target_hour(
        target_hour,
        time_schedule;
        japanese=japanese
    )

    if japanese == true
        lt = "粒径(mm)"
    else
        lt = "Size(mm)"
    end

    sediment_size_num = size(sediment_size, 1)

    target_matrix = Matrix(
        main_df.tuple[target_df][
            start_index:finish_index,
            DataFrames.Between(:Qs01, Symbol(string(:Qs, Printf.@sprintf("%02i", sediment_size_num))))
        ]
    )

    reverse!(target_matrix, dims=2)
    cumsum!(target_matrix, target_matrix, dims=2)
    reverse!(target_matrix, dims=2)
    reverse!(target_matrix, dims=1)

    strings_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3))

    p=vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    plot!(p, ylabel=yl, xlims=(0,77.8),ylims=(0,100),
          title=want_title, xlabel=xl,
          xticks=[0, 20, 40, 60, 77.8],
          linewidth=2, legend=:outerright,
	  palette=:tab20,
	  legend_font_pointsize=9,
          label_title=lt,
          legend_title_font_pointsize=10)

    for i in 1:sediment_size_num
        plot!(p, main_df.tuple[target_df][main_df.tuple[target_df].T .== 0, :I].*10^-3,
	      target_matrix[:,i],
	      fillrange=0,
	      label=strings_sediment_size[i])
    end

    return p
    
end

"""
特定の時間における粒径階別の掃流砂量の縦断分布のグラフを作る。
"""
function make_graph_bedload_target_hour(
    main_df::Main_df,
    target_hour::Int,
    time_schedule::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame;
    target_df::Int=1,
    japanese::Bool=false
    )
    
    target_second,
    start_index,
    finish_index,
    want_title,
    yl,
    xl = _core_make_graph_bedload_target_hour(
        target_hour,
        time_schedule;
        japanese=japanese
    )

    if japanese == true
        lt = "粒径(mm)"
    else
        lt = "Size(mm)"
    end

    sediment_size_num = size(sediment_size, 1)

    target_matrix = Matrix(
        main_df.tuple[target_df][
            start_index:finish_index,
            DataFrames.Between(:Qb01, Symbol(string(:Qb, Printf.@sprintf("%02i", sediment_size_num))))
        ]
    )

    reverse!(target_matrix, dims=2)
    cumsum!(target_matrix, target_matrix, dims=2)
    reverse!(target_matrix, dims=2)
    reverse!(target_matrix, dims=1)

    strings_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3))

    p=vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    plot!(p, ylabel=yl, xlims=(0,77.8),ylims=(0,2),
          title=want_title, xlabel=xl,
          xticks=[0, 20, 40, 60, 77.8],
          linewidth=2, legend=:outerright,
          palette=:tab20,
          legend_font_pointsize=9,
          label_title=lt,
          legend_title_font_pointsize=10)

    for i in 1:sediment_size_num
        plot!(p, main_df.tuple[target_df][main_df.tuple[target_df].T .== 0, :I].*10^-3,
              target_matrix[:,i],
              fillrange=0,
              label=strings_sediment_size[i])
    end

    return p

end

"""
特定の時間における粒径階別の浮遊砂量（上図）と掃流砂量（下図）の縦断分布のグラフを作る。
"""
function make_graph_suspended_bedload_target_hour(
    main_df::Main_df,
    target_hour::Int,
    time_schedule::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame;
    target_df::Int=1,
    japanese::Bool=false
    )
    
    l = @layout[a; b]

    p1 = make_graph_suspended_load_target_hour(
        main_df,
        target_hour,
        time_schedule,
        sediment_size;
        target_df=target_df,
        japanese=japanese
    )
    
    plot!(p1, xlabel="",
          legend_font_pointsize=4)

    p2 = make_graph_bedload_target_hour(
        main_df,
        target_hour,
        time_schedule,
        sediment_size;
        target_df=target_df,
        japanese=japanese        
    )

    plot!(p2, legend_font_pointsize=4)

    plot(p1, p2, layout=l)
    
end


"""
様々な解析の年平均の浮遊砂量の縦断分布を示すグラフを作る。
"""
function plot_yearly_mean_suspended_load(
    main_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    :Qsall
        )

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1
        )

    end

    return p

end

function plot_yearly_mean_suspended_load(
    main_df::Main_df,
    start_year::Int,
    final_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString, Each_year_timing}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            df_vararg[i][3],
	    :Qsall
        )

        sediment_load_yearly_mean .= sediment_load_yearly_mean / 10^6

        reverse!(sediment_load_yearly_mean)

        plot!(
            p,
            X,
            sediment_load_yearly_mean,
	    label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1
        )

    end

    return p

end

function plot_yearly_mean_suspended_load(
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_yearly_mean!(
        p,
        main_df,
        max_df,
        min_df,
        X,
        start_year,
        final_year,
        each_year_timing,
        flow_size,
        :Qsall,
        df_vararg,
        Val(N)
    )

    return p

end

function _plot_yearly_mean_suspended_load(
    start_year::Int,
    final_year::Int,
    japanese::Bool,
    X::AbstractVector{<:AbstractFloat}
    )

    title_s = string(start_year, "-", final_year)

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="浮遊砂量 (10^6 m³/年)"
    else
        x_label = "Distance from the estuary (km)"
        y_label = "Suspended sediment load\n(10⁶ m³/year)"
    end

    p = plot(
    	title=title_s,
	xlabel=x_label,
     	xlims=(X[begin], X[end]),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
    	ylims=(0, 10),
    	legend=:best,
        palette=:Set1_9,
        xflip=true
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)

    return p

end

"""
ある解析の複数の期間における年平均の浮遊砂量の縦断分布のグラフを作る。
"""
function make_graph_yearly_mean_suspended_load_per_case(
    df_main::Main_df,
    target_index::Int,
    each_year_timing::Each_year_timing,
    final_year::Int,
    start_year::Vararg{Int, N};
    japanese::Bool=false
    ) where {N}

    flow_size = length(df_main.tuple[target_index][df_main.tuple[target_index].T .== 0, :I])

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="浮遊砂量 (10⁶ m³/年)"
    else
        x_label = "Distance from the estuary (km)"
        y_label = "SSL (10⁶ m³/year)"
    end

    p = plot(
	xlabel=x_label,
     	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
    	ylims=(0, 6),
    	legend=:best,
        palette=:default,
        xflip=true,
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)

    X = [0.2*(i-1) for i in 1:flow_size]

    for i in 1:N

        sediment_load_yearly_mean = zeros(Float64, flow_size)

        if i == N
            last_year = final_year
        else
            last_year = start_year[i+1] - 1
        end

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    df_main.tuple[target_index],
            start_year[i],
            last_year,
            each_year_timing,
	    :Qsall
        )

        legend_label = string(start_year[i], "-", last_year)

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean ./ 1e6),
	    label=legend_label,
            linecolor=palette(:default)[i],
            linewidth=2
        )

    end

    return p

end

function plot_yearly_mean_bedload(
    main_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_bedload(
        start_year,
        final_year,
        japanese,
        X
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    :Qball
        )

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=df_vararg[i][2],            
            linecolor=palette(:Set1_9)[i],
            linewidth=1
        )

    end

    return p

end

function plot_yearly_mean_bedload(
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_bedload(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_yearly_mean!(
        p,
        main_df,
        max_df,
        min_df,
        X,
        start_year,
        final_year,
        each_year_timing,
        flow_size,
        :Qball,
        df_vararg,
        Val(N)
    )

    return p

end

function plot_yearly_mean_bedload(
    main_df::Main_df,
    start_year::Int,
    final_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString, Each_year_timing}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_bedload(
        start_year,
        final_year,
        japanese,
        X
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            df_vararg[i][3],
	    :Qball
        )

        sediment_load_yearly_mean .= sediment_load_yearly_mean / 10^3

        reverse!(sediment_load_yearly_mean)

        plot!(
            p,
            X,
            sediment_load_yearly_mean,
	    label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1
        )

    end

    return p

end

function _plot_yearly_mean_bedload(
    start_year::Int,
    final_year::Int,
    japanese::Bool,
    X::AbstractVector{<:AbstractFloat}
    )

    title_s = string(start_year, "-", final_year)

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="掃流砂量 (10^3 m³/年)"
    else
        x_label = "Distance from the estuary (km)"
        y_label = "Bedload (10³ m³/year)"
    end

    p = plot(
    	title=title_s,
	xlabel=x_label,
     	xlims=(X[begin], X[end]),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
    	ylims=(0, 100),
    	legend=:best,
        palette=:Set1_9,
        xflip=true
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)

    return p

end

function _plot_yearly_mean!(
    p::Plots.Plot,
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    X::AbstractVector{<:AbstractFloat},
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    flow_size::Int,
    symbol_sediment::Symbol,
    df_vararg::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N}

    sediment_load_yearly_mean = zeros(Float64, flow_size)
    sediment_load_yearly_max  = zeros(Float64, flow_size)
    sediment_load_yearly_min  = zeros(Float64, flow_size)

    _make_graph_yearly_mean!(
        p,
        main_df,
        max_df,
        min_df,
        sediment_load_yearly_mean,
        sediment_load_yearly_max,
        sediment_load_yearly_min,
        X,
        start_year,
        final_year,
        each_year_timing,
        flow_size,
        symbol_sediment,
        df_vararg,
        Val(N)
    )

end

function _make_graph_yearly_mean!(
    p::Plots.Plot,
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    sediment_load_yearly_mean::AbstractVector{T},
    sediment_load_yearly_max::AbstractVector{T},
    sediment_load_yearly_min::AbstractVector{T},
    X::AbstractVector{T},
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    flow_size::Int,
    symbol_sediment::Symbol,
    df_vararg::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N, T<:AbstractFloat}

    X_temp = reverse(X)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0
        sediment_load_yearly_max  .= 0.0
        sediment_load_yearly_min  .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_max,
            flow_size,
	    max_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_min,
            flow_size,
	    min_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
            symbol_sediment
        )

        if symbol_sediment == :Qball
            sediment_load_yearly_mean .= sediment_load_yearly_mean ./ 10^3
            sediment_load_yearly_max  .= sediment_load_yearly_max  ./ 10^3
            sediment_load_yearly_min  .= sediment_load_yearly_min  ./ 10^3
        elseif symbol_sediment == :Qsall
            sediment_load_yearly_mean .= sediment_load_yearly_mean ./ 10^6
            sediment_load_yearly_max  .= sediment_load_yearly_max  ./ 10^6
            sediment_load_yearly_min  .= sediment_load_yearly_min  ./ 10^6
        end

        plot!(
            p,
            X_temp,
            sediment_load_yearly_mean,
	    label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1,
            ribbon=(
                sediment_load_yearly_mean .- sediment_load_yearly_min,
                sediment_load_yearly_max  .- sediment_load_yearly_mean
            ),
            fillcolor=palette(:Set1_9)[i],
            fillalpha = 0.3
        )

    end

end

"""
ある解析の複数の期間における年平均の掃流砂量の縦断分布のグラフを作る。
"""
function make_graph_yearly_mean_bed_load_per_case(
    df_main::Main_df,
    target_index::Int,
    each_year_timing::Each_year_timing,
    final_year::Int,
    start_year::Vararg{Int, N};
    japanese::Bool=false
    ) where {N}

    flow_size = length(df_main.tuple[target_index][df_main.tuple[target_index].T .== 0, :I])

    if japanese==true 
        x_label="河口からの距離 (km)"
        y_label="掃流砂量 (10³ m³/年)"
    else
        x_label = "Distance from the estuary (km)"
        y_label = "Bedload (10³ m³/year)"
    end

    p = plot(
	xlabel=x_label,
     	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
    	ylims=(0, 50),
    	legend=:topright,
        palette=:default,
        xflip=true
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)

    X = [0.2*(i-1) for i in 1:flow_size]

    for i in 1:N

        sediment_load_yearly_mean = zeros(Float64, flow_size)

        if i == N 
            last_year = final_year
        else 
            last_year = start_year[i+1] - 1
        end

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    df_main.tuple[target_index],
            start_year[i],
            last_year,
            each_year_timing,
	    :Qball
        )

        legend_label = string(start_year[i], "-", last_year)

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean) ./ 1e3,
	    label=legend_label,
            linecolor=palette(:default)[i],
            linewidth=2
        )

    end

    return p

end

function stack_yearly_mean_sediment_load_each_size_whole_area!(
    sediment_load_each_size,
    sediment_size_num::Int,
    flow_size::Int,
    df::DataFrame,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    tag::Symbol
    )

    for i in 1:sediment_size_num 

        sediment_load_yearly_mean = zeros(Float64, flow_size)

        each_size_tag = Symbol(string(tag, @sprintf("%02i", i)))

        core_yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
            df,
            start_year,
            final_year,
            each_year_timing,
            each_size_tag
        )
        
        sediment_load_each_size[:,i].=sediment_load_yearly_mean
        
    end
    
    reverse!(cumsum!(sediment_load_each_size,reverse!(sediment_load_each_size, dims=2), dims=2), dims=2)    
    
    return sediment_load_each_size    

end

function _plot_particle_yearly_mean!(
    p::Plots.AbstractPlot,
    X::AbstractVector{<:AbstractFloat},
    main_df::Main_df,
    index_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    flow_size::Int,
    japanese::Bool,
    sediment_symbol::Symbol
    )


    sediment_size_num = size(sediment_size[:, :Np], 1)


    if japanese
        legend_t= "粒径 (mm)"
    else
        legend_t= "Size (mm)"
    end

    plot!(
        p,
        legend_title = legend_t,
        legend = :outerright
    )

    sediment_load_each_size = zeros(flow_size, sediment_size_num)

    stack_yearly_mean_sediment_load_each_size_whole_area!(
        sediment_load_each_size,
        sediment_size_num,
        flow_size,
        main_df.tuple[index_df],
        start_year,
        final_year,
        each_year_timing,
        sediment_symbol
    )

    palette_sediment_size = palette(
        :tab20
    )

    reverse!(X)

    for i in axes(sediment_load_each_size, 2)

        if i == 1
            s_label = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            s_label = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            s_label = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            s_label = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        plot!(
            p,
            X,
            sediment_load_each_size[:,i],
            label = s_label,
            fillrange=0,
            linewidth=1,
            color=palette_sediment_size[i],
            linecolor=:gray
        )

    end

    return nothing

end

"""
粒径階別の年平均の浮遊砂量の縦断分布を示すグラフを作成する。
"""
function plot_particle_yearly_mean_suspended(
    main_df::Main_df,
    index_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_particle_yearly_mean!(
        p,
        X,
        main_df,
        index_df,
        start_year,
        final_year,
        each_year_timing,
        sediment_size,
        flow_size,
        japanese,
        :Qsall
    )

    return p

end

"""
粒径階別の年平均の掃流砂のグラフを作成する
"""
function plot_particle_yearly_mean_bedload(
    main_df::Main_df,
    index_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_bedload(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_particle_yearly_mean!(
        p,
        X,
        main_df,
        index_df,
        start_year,
        final_year,
        each_year_timing,
        sediment_size,
        flow_size,
        japanese,
        :Qball
    )

    return p

end

"""
各粒径階の年平均浮遊砂量の条件による変化率のグラフを作成する。
縦断分布を示す。
"""
function plot_condition_rate_particle_yearly_mean_suspended_load(
    main_df::Main_df,
    index_base_df::Int,
    index_target_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    sediment_size_num = size(sediment_size[:, :Np], 1)

    p = GeneralGraphModule._plot_condition_rate_yearly_mean(
        X,
        start_year,
        final_year,
        japanese
    )

    if japanese
        legend_t= "粒径 (mm)"
    else
        legend_t= "Size (mm)"
    end

    plot!(
        legend_title = legend_t,
        legend=:outerright
    )

    sediment_load_yearly_mean_base = zeros(Float64, flow_size)
    sediment_load_yearly_mean = zeros(Float64, flow_size)

    for i in 1:sediment_size_num

        if i == 1
            s_label = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            s_label = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            s_label = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            s_label = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        sediment_load_yearly_mean_base .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean_base,
            flow_size,
            main_df.tuple[index_base_df],
            start_year,
            final_year,
            each_year_timing,
            Symbol(@sprintf("Qsall%02i", i))
        )

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
            main_df.tuple[index_target_df],
            start_year,
            final_year,
            each_year_timing,
            Symbol(@sprintf("Qsall%02i", i))
        )

        sediment_load_yearly_mean .=
            ((sediment_load_yearly_mean ./ sediment_load_yearly_mean_base) .- 1.0) .* 100

        reverse!(X)

        plot!(
            p,
            X,
            sediment_load_yearly_mean,
	    label=s_label,
            linecolor=palette(:tab20)[i],
            linewidth=1
        )

    end

    return p

end

"""
各粒径階の年平均掃流砂の条件による変化率のグラフを作成する。
縦断分布を示す。
"""
function plot_condition_rate_particle_yearly_mean_bedload(
    main_df::Main_df,
    index_base_df::Int,
    index_target_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    sediment_size_num = size(sediment_size[:, :Np], 1)

    p = GeneralGraphModule._plot_condition_rate_yearly_mean(
        X,
        start_year,
        final_year,
        japanese
    )

    if japanese
        legend_t= "粒径 (mm)"
    else
        legend_t= "Size (mm)"
    end

    plot!(
        legend_title = legend_t,
        legend=:outerright
    )

    sediment_load_yearly_mean_base = zeros(Float64, flow_size)
    sediment_load_yearly_mean = zeros(Float64, flow_size)

    for i in 1:sediment_size_num

        if i == 1
            s_label = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            s_label = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            s_label = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            s_label = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        sediment_load_yearly_mean_base .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean_base,
            flow_size,
            main_df.tuple[index_base_df],
            start_year,
            final_year,
            each_year_timing,
            Symbol(@sprintf("Qball%02i", i))
        )

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
            main_df.tuple[index_target_df],
            start_year,
            final_year,
            each_year_timing,
            Symbol(@sprintf("Qball%02i", i))
        )

        sediment_load_yearly_mean .=
            ((sediment_load_yearly_mean ./ sediment_load_yearly_mean_base) .- 1.0) .* 100

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=s_label,
            linecolor=palette(:tab20)[i],
            linewidth=1
        )

    end

    return p

end


function percentage_sediment_load_each_size!(
    sediment_load_each_size::AbstractMatrix,
    flow_size::Int,
    df::DataFrame,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    tag::Symbol
    )

    for i in axes(sediment_load_each_size, 2)

        each_size_tag = Symbol(string(tag, @sprintf("%02i", i)))

        core_yearly_mean_sediment_load_whole_area!(
            view(sediment_load_each_size, :, i),
            flow_size,
            df,
            start_year,
            final_year,
            each_year_timing,
            each_size_tag
        )

    end

    sum_sediment_load = sum(sediment_load_each_size, dims=2)

    for i in axes(sediment_load_each_size, 2)
        sediment_load_each_size[:, i] .=
            sediment_load_each_size[:, i] ./ sum_sediment_load[:] .* 100
    end

    return sediment_load_each_size

end

function _plot_percentage_particle_yearly_mean!(
    p::Plots.AbstractPlot,
    X::AbstractVector{<:AbstractFloat},
    main_df::Main_df,
    index_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    flow_size::Int,
    japanese::Bool,
    sediment_symbol::Symbol
    )

    if japanese
        legend_t= "粒径 (mm)"
        y_label="割合 (%)"
    else
        legend_t= "Size (mm)"
        y_label = "Percentage (%)"
    end

    plot!(
        p,
        legend_title = legend_t,
        legend = :outerright
    )

    sediment_size_num = size(sediment_size[:, :Np], 1)

    sediment_load_each_size = zeros(flow_size, sediment_size_num)

    percentage_sediment_load_each_size!(
        sediment_load_each_size,
        flow_size,
        main_df.tuple[index_df],
        start_year,
        final_year,
        each_year_timing,
        sediment_symbol
    )


    reverse!(sediment_load_each_size, dims=2)
    cumsum!(sediment_load_each_size, sediment_load_each_size, dims=2)
    reverse!(sediment_load_each_size, dims=2)

    palette_sediment_size = palette(
        :tab20
    )

    reverse!(X)

    for i in axes(sediment_load_each_size, 2)

        if i == 1
            s_label = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            s_label = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            s_label = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            s_label = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        plot!(
            p,
            X,
            view(sediment_load_each_size, :, i),
            label = s_label,
            ylabel= y_label,
            fillrange=0,
            linewidth=1,
            color=palette_sediment_size[i],
            linecolor=:gray,
            ylims=(0, 100)
        )

    end

    return nothing

end

function plot_percentage_particle_yearly_mean_suspended(
    main_df::Main_df,
    index_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_percentage_particle_yearly_mean!(
        p,
        X,
        main_df,
        index_df,
        start_year,
        final_year,
        each_year_timing,
        sediment_size,
        flow_size,
        japanese,
        :Qsall
    )

    return p

end

function plot_percentage_particle_yearly_mean_bedload(
    main_df::Main_df,
    index_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_percentage_particle_yearly_mean!(
        p,
        X,
        main_df,
        index_df,
        start_year,
        final_year,
        each_year_timing,
        sediment_size,
        flow_size,
        japanese,
        :Qball
    )

    return p

end


function _plot_condition_percentage_point_particle_yearly_mean!(
    p::Plots.AbstractPlot,
    X::AbstractVector{<:AbstractFloat},
    main_df::Main_df,
    index_df_base::Int,
    index_df_condition::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    flow_size::Int,
    japanese::Bool,
    sediment_symbol::Symbol
    )

    if japanese
        legend_t= "粒径 (mm)"
        y_label="パーセントポイント (%pt)"
    else
        legend_t= "Size (mm)"
        y_label = "Percentage point (%pt)"
    end

    plot!(
        p,
        legend_title = legend_t,
        legend = :outerright
    )

    sediment_size_num = size(sediment_size[:, :Np], 1)

    sediment_load_each_size_base = zeros(flow_size, sediment_size_num)
    percentage_sediment_load_each_size!(
        sediment_load_each_size_base,
        flow_size,
        main_df.tuple[index_df_base],
        start_year,
        final_year,
        each_year_timing,
        sediment_symbol
    )

    sediment_load_each_size      = zeros(flow_size, sediment_size_num)
    percentage_sediment_load_each_size!(
        sediment_load_each_size,
        flow_size,
        main_df.tuple[index_df_condition],
        start_year,
        final_year,
        each_year_timing,
        sediment_symbol
    )

    sediment_load_each_size .= sediment_load_each_size .- sediment_load_each_size_base
    fill_sediment_load_each_size = similar(sediment_load_each_size)

    GeneralGraphModule. calc_condition_percentage_point_to_plot!(
        sediment_load_each_size,
        fill_sediment_load_each_size
    )

    palette_sediment_size = palette(
        :tab20
    )

    reverse!(X)

    for i in axes(sediment_load_each_size, 2)

        if i == 1
            s_label = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            s_label = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            s_label = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            s_label = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        plot!(
            p,
            X,
            view(sediment_load_each_size, :, i),
            label = s_label,
            ylabel= y_label,
            linewidth=0,
            linecolor=:gray,
            color=palette_sediment_size[i],
            ylims=(-1, 1),
            fillrange=view(fill_sediment_load_each_size, :, i)
        )

    end

    hline!(
        p,
        [0],
        linewidth=1,
        linestyle=:dash,
        linecolor=:black,
        primary=false
    )

    return nothing

end

"""
粒度階別のパーセントポイントの変化 浮遊砂
"""
function plot_condition_percentage_point_particle_yearly_mean_suspended(
    main_df::Main_df,
    index_df_base::Int,
    index_df_condition::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_suspended_load(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_condition_percentage_point_particle_yearly_mean!(
        p,
        X,
        main_df,
        index_df_base,
        index_df_condition,
        start_year,
        final_year,
        each_year_timing,
        sediment_size,
        flow_size,
        japanese,
        :Qsall
    )

    return p

end

"""
粒度階別のパーセントポイントの変化 掃流砂
"""
function plot_condition_percentage_point_particle_yearly_mean_bedload(
    main_df::Main_df,
    index_df_base::Int,
    index_df_condition::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = _plot_yearly_mean_bedload(
        start_year,
        final_year,
        japanese,
        X
    )

    _plot_condition_percentage_point_particle_yearly_mean!(
        p,
        X,
        main_df,
        index_df_base,
        index_df_condition,
        start_year,
        final_year,
        each_year_timing,
        sediment_size,
        flow_size,
        japanese,
        :Qball
    )

    return p

end


"""
浮遊砂の時系列変化のグラフを作成する
"""
function plot_time_series_suspended(
    df_main::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::Float64,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    p = GeneralGraphModule.plot_time_series_general(
        df_main::Main_df,
        index_area::Int,
        flow_size::Int,
        river_length_km::Float64,
        :Qs,
        japanese,
        df_vararg...
            )    

    if japanese == true
        y_label="浮遊砂量 (m³/s)"
    elseif japanese == false
        y_label="Suspended sediment\nload (m³/s)"
    end

    p = plot!(
        ylims=(-5, 145),
        ylabel=y_label
    )

    return p

end

"""
掃流砂の時系列変化のグラフを作成する
"""
function plot_time_series_bedload(
    df_main::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::Float64,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    p = GeneralGraphModule.plot_time_series_general(
        df_main::Main_df,
        index_area::Int,
        flow_size::Int,
        river_length_km::Float64,
        :Qb,
        japanese,
        df_vararg...
            ) 

    if japanese == true
        y_label="掃流砂量 (m³/s)"
    elseif japanese == false
        y_label="Bedload (m³/s)"
    end

    p = plot!(
        ylims=(-0.1, 2.1),
        ylabel=y_label
    )

    return p

end

"""
浮遊砂の時系列変化の条件による変化率のグラフを作成する。
"""
function plot_time_series_variation_suspended(
    df_main::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::Float64,
    index_df_base::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    p = GeneralGraphModule.plot_time_series_variation_general(
        df_main::Main_df,
        index_area::Int,
        flow_size::Int,
        river_length_km::Float64,
        :Qs,
        japanese,
        index_df_base,
        df_vararg...
        )   

    return p

end

"""
掃流砂の時系列変化の条件による変化率のグラフを作成する。
"""
function plot_time_series_variation_bedload(
    df_main::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::Float64,
    index_df_base::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    p = GeneralGraphModule.plot_time_series_variation_general(
        df_main::Main_df,
        index_area::Int,
        flow_size::Int,
        river_length_km::Float64,
        :Qb,
        japanese,
        index_df_base,
        df_vararg...
        )   

    return p

end

function make_graph_time_series_particle_suspended_load(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size::DataFrame;
    japanese::Bool=false
    )

    time_data = [3600.0 * i for i in 0:each_year_timing.dict[sort(collect(keys(each_year_timing.dict)))[end]][2]]
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    sediment_size_num = size(sediment_size[:, :Np], 1)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    

    if japanese == true

        x_label="時間 (s)"
        y_label="浮遊砂量 (m³/s)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")
        t_legend="粒径 (mm)"

    elseif japanese == false

        x_label="Time (s)"
        y_label="Suspended sediment load (m³/s)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")
        t_legend="Size (mm)"

    end

    p = plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
        ylims=(0, 140),
        ylabel=y_label,
        title=t_title,
        legend=:outerright,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
        palette=:tab20,
        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    sediment_time_series = zeros(Float64, num_time, sediment_size_num)

    for i in 1:sediment_size_num

        each_size_tag = Symbol(string("Qs", @sprintf("%02i", i)))

        for j in 1:num_time

            j_first, j_final = decide_index_number(j-1)

            sediment_time_series[j, i] = df[j_first:j_final, each_size_tag][area_index]

        end
        
    end

    reverse!(cumsum!(sediment_time_series, reverse!(sediment_time_series, dims=2), dims=2), dims=2)

    for i in 1:sediment_size_num

        plot!(
            p,
            time_data,
            sediment_time_series[:, i],
            label=round(sediment_size[i, 3]; sigdigits=3),
            fillrange=0,
            linewidth=1
        )

    end

    return p

end

function make_graph_time_series_particle_bedload(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size::DataFrame;
    japanese::Bool=false
    )

    time_data = [3600.0 * i for i in 0:each_year_timing.dict[sort(collect(keys(each_year_timing.dict)))[end]][2]]
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    sediment_size_num = size(sediment_size[:, :Np], 1)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    

    if japanese == true

        x_label="時間 (s)"
        y_label="掃流砂量 (m³/s)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")
        t_legend="粒径 (mm)"

    elseif japanese == false

        x_label="Time (s)"
        y_label="Bedload (m³/s)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")
        t_legend="Size (mm)"

    end

    p = plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
        ylims=(0, 2.5),
        ylabel=y_label,
        title=t_title,
        legend=:outerright,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
        palette=:tab20,
        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    sediment_time_series = zeros(Float64, num_time, sediment_size_num)

    for i in 1:sediment_size_num

        each_size_tag = Symbol(string("Qb", @sprintf("%02i", i)))

        for j in 1:num_time

            j_first, j_final = decide_index_number(j-1)

            sediment_time_series[j, i] = df[j_first:j_final, each_size_tag][area_index]

        end
        
    end

    reverse!(cumsum!(sediment_time_series, reverse!(sediment_time_series, dims=2), dims=2), dims=2)

    for i in 1:sediment_size_num

        plot!(
            p,
            time_data,
            sediment_time_series[:, i],
            label=round(sediment_size[i, 3]; sigdigits=3),
            fillrange=0,
            linewidth=1
        )

    end

    return p

end

function make_graph_time_series_particle_suspended_bedload(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size;
    japanese::Bool=false
    )
    
    l = @layout[a;b]
    
    area_km = abs(river_length_km - 0.2 * (area_index - 1))
    
    if japanese == true
        t_title = string("河口から ", round(area_km, digits=2), " km 上流")
        y_label = "浮遊砂量 (m³/s)"
    elseif japanese == false
        t_title = string(round(area_km, digits=2), " km upstream from the estuary")
        y_label = "Suspended (m³/s)"
    end
    
    p1 = make_graph_time_series_particle_suspended_load(
        area_index,
        river_length_km,
        each_year_timing,
        df,
        sediment_size,
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[],
          title=string(t_title),
          ylabel=y_label
          )
    
    p2 = make_graph_time_series_particle_bedload(
        area_index,
        river_length_km,
        each_year_timing,
        df,
        sediment_size,
        japanese=japanese
    )
    
    plot!(p2, 
          legend=:none
          )

    p = plot(p1, p2, layout=l, 
             legend_font_pointsize=6,
             legend_title_font_pointsize=6,   
             )
    
    return p
    
end

function make_graph_time_series_percentage_particle_suspended_load(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size::DataFrame;
    japanese::Bool=false
    )

    time_data = [3600.0 * i for i in 0:each_year_timing.dict[sort(collect(keys(each_year_timing.dict)))[end]][2]]
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    sediment_size_num = size(sediment_size[:, :Np], 1)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    

    if japanese == true

        x_label="時間 (s)"
        y_label="割合 (%)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")
        t_legend="粒径 (mm)"

    elseif japanese == false

        x_label="Time (s)"
        y_label="Percentage (%)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")
        t_legend="Size (mm)"

    end

    p = plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
        ylims=(0, 100),
        ylabel=y_label,
        title=t_title,
        legend=:outerright,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
        palette=:tab20,
        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    sediment_time_series = zeros(Float64, num_time, sediment_size_num)

    for i in 1:sediment_size_num

        each_size_tag = Symbol(string("Qs", @sprintf("%02i", i)))

        for j in 1:num_time

            j_first, j_final = decide_index_number(j-1)

            sediment_time_series[j, i] = df[j_first:j_final, each_size_tag][area_index]

        end
        
    end

    for j in 1:num_time

        normalize!(@view(sediment_time_series[j,:]), 1)

    end

    sediment_time_series = sediment_time_series * 100

    reverse!(cumsum!(sediment_time_series, reverse!(sediment_time_series, dims=2), dims=2), dims=2)

    for i in 1:sediment_size_num

        plot!(
            p,
            time_data,
            sediment_time_series[:, i],
            label=round(sediment_size[i, 3]; sigdigits=3),
            fillrange=0,
            linewidth=1
        )

    end

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )    

    return p

end

function make_graph_time_series_percentage_particle_bedload(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size::DataFrame;
    japanese::Bool=false
    )

    time_data = [3600.0 * i for i in 0:each_year_timing.dict[sort(collect(keys(each_year_timing.dict)))[end]][2]]
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    sediment_size_num = size(sediment_size[:, :Np], 1)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    

    if japanese == true

        x_label="時間 (s)"
        y_label="割合 (%)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")
        t_legend="粒径 (mm)"

    elseif japanese == false

        x_label="Time (s)"
        y_label="Percentage (%)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")
        t_legend="Size (mm)"

    end

    p = plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
        ylims=(0, 100),
        ylabel=y_label,
        title=t_title,
        legend=:outerright,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
        palette=:tab20,
        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    sediment_time_series = zeros(Float64, num_time, sediment_size_num)

    for i in 1:sediment_size_num

        each_size_tag = Symbol(string("Qb", @sprintf("%02i", i)))

        for j in 1:num_time

            j_first, j_final = decide_index_number(j-1)

            sediment_time_series[j, i] = df[j_first:j_final, each_size_tag][area_index]

        end
        
    end

    for j in 1:num_time

        normalize!(@view(sediment_time_series[j,:]), 1)

    end

    sediment_time_series = sediment_time_series * 100

    reverse!(cumsum!(sediment_time_series, reverse!(sediment_time_series, dims=2), dims=2), dims=2)

    for i in 1:sediment_size_num

        plot!(
            p,
            time_data,
            sediment_time_series[:, i],
            label=round(sediment_size[i, 3]; sigdigits=3),
            fillrange=0,
            linewidth=1
        )

    end

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )    

    return p

end

function make_graph_time_series_amount_percentage_particle_suspended_load(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size;
    japanese::Bool=false
    )
    
    l = @layout[a;b]
    
    area_km = abs(river_length_km - 0.2 * (area_index - 1))
    
    if japanese == true
        t_title = string("河口から ", round(area_km, digits=2), " km 上流")
        y_label = "浮遊砂量 (m³/s)"
    elseif japanese == false
        t_title = string(round(area_km, digits=2), " km upstream from the estuary")
        y_label = "Suspended (m³/s)"
    end
    
    p1 = make_graph_time_series_particle_suspended_load(
        area_index,
        river_length_km,
        each_year_timing,
        df,
        sediment_size,
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[],
          title=string(t_title),
          ylabel=y_label
          )
    
    p2 = make_graph_time_series_percentage_particle_suspended_load(
        area_index,
        river_length_km,
        each_year_timing,
        df,
        sediment_size;
        japanese=japanese
    )
    
    plot!(p2,
          legend=:none
          )

    p = plot(p1, p2, layout=l, 
             legend_font_pointsize=6,
             legend_title_font_pointsize=6,   
             )
    
    return p
    
end

function make_graph_time_series_amount_percentage_particle_bedload(
    area_index::Int,
    river_length_km::Float64,
    each_year_timing::Each_year_timing,
    df::DataFrame,
    sediment_size;
    japanese::Bool=false
    )
    
    l = @layout[a;b]
    
    area_km = abs(river_length_km - 0.2 * (area_index - 1))
    
    if japanese == true
        t_title = string("河口から ", round(area_km, digits=2), " km 上流")
    elseif japanese == false
        t_title = string(round(area_km, digits=2), " km upstream from the estuary")
    end
    
    p1 = make_graph_time_series_particle_bedload(
        area_index,
        river_length_km,
        each_year_timing,
        df,
        sediment_size,
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[],
          title=string(t_title)
          )
    
    p2 = make_graph_time_series_percentage_particle_bedload(
        area_index,
        river_length_km,
        each_year_timing,
        df,
        sediment_size;
        japanese=japanese
    )
    
    plot!(p2,
          legend=:none
          )

    p = plot(p1, p2, layout=l, 
             legend_font_pointsize=6,
             legend_title_font_pointsize=6,   
             )
    
    return p
    
end

function plot_condition_change_particle_yearly_mean_suspended_load(
    main_df::Main_df,
    index_base_df::Int,
    index_target_df::Int,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame;
    flow_size::Int=390,
    japanese::Bool=false
    )

    title_s = string(start_year, "-", final_year)

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化量 (m³/年)"
    else
        x_label = "Distance from the estuary (km)"
        y_label = "Variation (m³/year)"
    end

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = Plots.plot(
    	title=title_s,
    	xlabel=x_label,
    	xlims=(X[begin], X[end]),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
	legend=:best,
        palette=:Set1_3,
        xflip=true
        )

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, linestyle=:dash, linewidth=1, primary=:false)
    Plots.hline!(p, [0], line=:black, linestyle=:dot, linewidth=1, primary=:false)

    if japanese
        legend_t= "粒径 (mm)"
    else
        legend_t= "Size (mm)"
    end

    plot!(
        legend_title = legend_t,
        legend=:outerright
    )

    sediment_load_yearly_mean_base = zeros(Float64, flow_size)
    sediment_load_yearly_mean      = zeros(Float64, flow_size)
    sediment_load_yearly_change    = zeros(Float64, flow_size)

    for i in 1:size(sediment_size)[1]

        if i == 1
            s_label = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            s_label = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            s_label = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            s_label = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        sediment_load_yearly_mean_base .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean_base,
            flow_size,
            main_df.tuple[index_base_df],
            start_year,
            final_year,
            each_year_timing,
            Symbol(@sprintf("Qsall%02i", i))
        )

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
            main_df.tuple[index_target_df],
            start_year,
            final_year,
            each_year_timing,
            Symbol(@sprintf("Qsall%02i", i))
        )

        sediment_load_yearly_change .= 0.0

        sediment_load_yearly_change .=
            (sediment_load_yearly_mean .- sediment_load_yearly_mean_base)

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_change),
	    label=s_label,
            linecolor=palette(:tab20)[i],
            linewidth=1
        )

    end

    return p

end

function make_graph_condition_change_yearly_mean_bedload(
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    )

    flow_size = length(df_base[df_base.T .== 0, :I])

    title_s = string(start_year, "-", final_year)
    
    if japanese==true 
        x_label="河口からの距離 (km)"
        y_label="変化量 (m³/年)"
        label_s = ["砂利採取", "池田ダム", "砂利採取と池田ダム"]        
    else
        x_label = "Distance from the estuary (km)"
        y_label = "Variation (m³/year)"
        label_s = [
            "by gravel mining (Case 3 - Case 4)",
            "by the Ikeda Dam (Case 2 - Case 4)",
            "by gravel mining and the Ikeda Dam (Case 1 - Case 4)"
        ]    
    end
    
    p = plot(
    	title=title_s,
	    xlabel=x_label,
	    xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
	    ylims=(-20000, 20000),
	    legend=:best,
        palette=:Set1_3,
        xflip=true
    )
    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=1)
    hline!(p, [0], line=:black, label="", linestyle=:dot, linewidth=1)    

    X = [0.2*(i-1) for i in 1:flow_size]    
    
    sediment_load_yearly_mean_base = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base,
        flow_size,
        df_base,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    sediment_load_yearly_mean_mining = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_mining,
        flow_size,
        df_with_mining,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    sediment_load_yearly_mean_mining .=
        sediment_load_yearly_mean_mining .- sediment_load_yearly_mean_base

    sediment_load_yearly_mean_dam = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_dam,
        flow_size,
        df_with_dam,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    sediment_load_yearly_mean_dam .=
        sediment_load_yearly_mean_dam .- sediment_load_yearly_mean_base

    sediment_load_yearly_mean_mining_dam = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_mining_dam,
        flow_size,
        df_with_mining_and_dam,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )
    
    sediment_load_yearly_mean_mining_dam .=
        sediment_load_yearly_mean_mining_dam .- sediment_load_yearly_mean_base

    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_mining_dam),
        label=label_s[3],
        linecolor=palette(:Set1_3)[1],
        linewidth=1
    )

    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_dam),
        label=label_s[2],
        linecolor=palette(:Set1_3)[2],
        linewidth=1
    )
    
    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_mining),
        label=label_s[1],
        linecolor=palette(:Set1_3)[3],
        linewidth=1
    )

    return p
    
end

function plot_condition_rate_yearly_mean_suspended_load(
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    index_base_df::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    p = plot_condition_rate_yearly_mean_sediment(
        main_df,
        max_df,
        min_df,
        start_year,
        final_year,
        each_year_timing,
        :Qsall,
        index_base_df,
        df_vararg...;
        flow_size=flow_size,
        japanese=japanese
    )

    plot!(
        p,
        ylims=(-45, 45)
    )

    return p
    
end

function plot_condition_rate_yearly_mean_bedload(
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    index_base_df::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    p = plot_condition_rate_yearly_mean_sediment(
        main_df,
        max_df,
        min_df,
        start_year,
        final_year,
        each_year_timing,
        :Qball,
        index_base_df,
        df_vararg...;
        flow_size=flow_size,
        japanese=japanese
    )

    plot!(
        p,
        ylims=(-120, 220)
    )

    return p

end

function plot_condition_rate_yearly_mean_sediment(
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    symbol_sediment::Symbol,
    index_base_df::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = GeneralGraphModule._plot_condition_rate_yearly_mean(
        X,
        start_year,
        final_year,
        japanese
    )

    _plot_condition_rate_yearly_mean!(
        p,
        main_df,
        max_df,
        min_df,
        X,
        start_year,
        final_year,
        each_year_timing,
        flow_size,
        symbol_sediment,
        index_base_df,
        df_vararg,
        Val(N)
    )

    return p

end

function plot_case_rate_yearly_mean_sediment(
    main_df::Main_df,
    base_df::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    symbol_sediment::Symbol,
    df_vararg::Vararg{Tuple{Int,<:AbstractString},N};
    flow_size::Int=390,
    japanese::Bool=false
) where {N}

    X = main_df.tuple[begin][1:flow_size, :I] ./ 1000

    p = GeneralGraphModule._plot_condition_rate_yearly_mean(
        X,
        start_year,
        final_year,
        japanese
    )

    plot!(
        p,
        ylabel=if japanese
            "変化率 (-)"
        else
            "Variation (-)"
        end
    )

    reverse!(X)

    sediment_load_yearly_mean = zeros(Float64, flow_size)
    sediment_load_yearly_mean_base = zeros(Float64, flow_size)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0
        sediment_load_yearly_mean_base .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean_base,
            flow_size,
            base_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        sediment_load_yearly_mean .=
            (sediment_load_yearly_mean ./ sediment_load_yearly_mean_base)

        plot!(
            p,
            X,
            sediment_load_yearly_mean,
            label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=2
        )


    end

    return p

end


function plot_condition_rate_percentage_point_yearly_mean_sediment(
    main_df::Main_df,
    main_df_base::Main_df,
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    symbol_sediment::Symbol,
    index_base_df::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = main_df.tuple[begin][1:flow_size , :I] ./ 1000

    p = GeneralGraphModule._plot_condition_rate_yearly_mean(
        X,
        start_year,
        final_year,
        japanese
    )

    plot!(
        p,
        ylabel = if japanese
            "パーセントポイント (%pt)"
        else
            "Percentage point (%pt)"
        end,
        ylims=(-50, 50)
    )

    sediment_load_yearly_mean_base = zeros(Float64, flow_size)
    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base,
        flow_size,
        main_df.tuple[index_base_df],
        start_year,
        final_year,
        each_year_timing,
        symbol_sediment
    )

    sediment_load_yearly_mean_base_1_base = zeros(Float64, flow_size)
    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base_1_base,
        flow_size,
        main_df_base.tuple[index_base_df],
        start_year,
        final_year,
        each_year_timing,
        symbol_sediment
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)
    sediment_load_yearly_mean_base_1 = zeros(Float64, flow_size)

    reverse!(X)

    for i in 1:N

        sediment_load_yearly_mean .= 0.0
        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
            main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
            symbol_sediment
        )
        sediment_load_yearly_mean .=
            ((sediment_load_yearly_mean ./ sediment_load_yearly_mean_base) .- 1) .* 100

        sediment_load_yearly_mean_base_1 .= 0.0
        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean_base_1,
            flow_size,
            main_df_base.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
            symbol_sediment
        )
        sediment_load_yearly_mean_base_1 .=
            ((sediment_load_yearly_mean_base_1 ./ sediment_load_yearly_mean_base_1_base) .- 1) .* 100

        sediment_load_yearly_mean .=
            sediment_load_yearly_mean .- sediment_load_yearly_mean_base_1

        plot!(
            p,
            X,
            sediment_load_yearly_mean,
            label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1,
            primary=true
        )

    end

    return p

end


function _plot_condition_rate_yearly_mean!(
    p::Plots.Plot,
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    X::AbstractVector{T},
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    flow_size::Int,
    symbol_sediment::Symbol,
    index_base_df::Int,
    df_vararg::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N, T<:AbstractFloat}

    sediment_load_yearly_mean_base = zeros(Float64, flow_size)
    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base,
        flow_size,
        main_df.tuple[index_base_df],
        start_year,
        final_year,
        each_year_timing,
        symbol_sediment
    )

    sediment_load_yearly_max_base = zeros(Float64, flow_size)
    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_max_base,
        flow_size,
        main_df.tuple[index_base_df],
        start_year,
        final_year,
        each_year_timing,
        symbol_sediment
    )

    sediment_load_yearly_min_base = zeros(Float64, flow_size)
    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_min_base,
        flow_size,
        main_df.tuple[index_base_df],
        start_year,
        final_year,
        each_year_timing,
        symbol_sediment
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)
    sediment_load_yearly_max  = zeros(Float64, flow_size)
    sediment_load_yearly_min  = zeros(Float64, flow_size)

    _plot_condition_rate_yearly_mean!(
        p,
        main_df,
        max_df,
        min_df,
        sediment_load_yearly_mean_base,
        sediment_load_yearly_max_base,
        sediment_load_yearly_min_base,
        sediment_load_yearly_mean,
        sediment_load_yearly_max,
        sediment_load_yearly_min,
        X,
        start_year,
        final_year,
        each_year_timing,
        flow_size,
        symbol_sediment,
        df_vararg,
        Val(N)
    )    

end

function _plot_condition_rate_yearly_mean!(
    p::Plots.Plot,
    main_df::Main_df,
    X::AbstractVector{T},
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    flow_size::Int,
    symbol_sediment::Symbol,
    index_base_df::Int,
    df_vararg::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N, T<:AbstractFloat}

    sediment_load_yearly_mean_base = zeros(Float64, flow_size)
    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base,
        flow_size,
        main_df.tuple[index_base_df],
        start_year,
        final_year,
        each_year_timing,
        symbol_sediment
    )

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    _plot_condition_rate_yearly_mean!(
        p,
        main_df,
        sediment_load_yearly_mean_base,
        sediment_load_yearly_mean,
        X,
        start_year,
        final_year,
        each_year_timing,
        flow_size,
        symbol_sediment,
        df_vararg,
        Val(N)
    )

end

function _plot_condition_rate_yearly_mean!(
    p::Plots.Plot,
    main_df::Main_df,
    max_df::Main_df,
    min_df::Main_df,
    sediment_load_yearly_mean_base::AbstractVector{T},
    sediment_load_yearly_max_base::AbstractVector{T},
    sediment_load_yearly_min_base::AbstractVector{T},
    sediment_load_yearly_mean::AbstractVector{T},
    sediment_load_yearly_max::AbstractVector{T},
    sediment_load_yearly_min::AbstractVector{T},
    X::AbstractVector{T},
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    flow_size::Int,
    symbol_sediment::Symbol,
    df_vararg::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N, T<:AbstractFloat}

    for i in 1:N

        sediment_load_yearly_mean .= 0.0
        sediment_load_yearly_max  .= 0.0
        sediment_load_yearly_min  .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_max,
            flow_size,
	    max_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_min,
            flow_size,
	    min_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
            symbol_sediment
        )

        sediment_load_yearly_mean .=
            ((sediment_load_yearly_mean ./ sediment_load_yearly_mean_base) .- 1.0) .* 100

        sediment_load_yearly_max .=
            ((sediment_load_yearly_max  ./ sediment_load_yearly_max_base)  .- 1.0) .* 100

        sediment_load_yearly_min .=
            ((sediment_load_yearly_min  ./ sediment_load_yearly_min_base)  .- 1.0) .* 100

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1,
            ribbon=(
                reverse!(sediment_load_yearly_mean .- sediment_load_yearly_min),
                reverse!(sediment_load_yearly_max  .- sediment_load_yearly_mean)
            ),
            fillcolor=palette(:Set1_9)[i],
            fillalpha = 0.3
        )

    end

end

function _plot_condition_rate_yearly_mean!(
    p::Plots.Plot,
    main_df::Main_df,
    sediment_load_yearly_mean_base::AbstractVector{T},
    sediment_load_yearly_mean::AbstractVector{T},
    X::AbstractVector{T},
    start_year::Int,
    final_year::Int,
    each_year_timing::Each_year_timing,
    flow_size::Int,
    symbol_sediment::Symbol,
    df_vararg::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N, T<:AbstractFloat}

    for i in 1:N

        sediment_load_yearly_mean .= 0.0

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    main_df.tuple[df_vararg[i][1]],
            start_year,
            final_year,
            each_year_timing,
	    symbol_sediment
        )

        sediment_load_yearly_mean .=
            ((sediment_load_yearly_mean ./ sediment_load_yearly_mean_base) .- 1.0) .* 100

        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=df_vararg[i][2],
            linecolor=palette(:Set1_9)[i],
            linewidth=1
        )

    end

end


"""
浮遊砂量の年平均値を粒径階別に積み上げたグラフを作る
"""
function make_figure_yearly_mean_particle_suspended_sediment_load_stacked(
        df_main::Main_df,
        target_df::Int,
        num_data_flow::Int,
        each_year_timing::Each_year_timing,
        start_year::Int,
        final_year::Int,
        sediment_size::DataFrame,
        area_index::Vararg{Tuple{Int, <:AbstractString}, N};
        japanese::Bool=false
    ) where {N}

    num_class_size = size(sediment_size, 1)

    if japanese == true
        ylabel="年平均浮遊砂量 (10^6 m³/year)"
        legend_title="粒径 (mm)"
    else
        ylabel="Annual average \nSSL (10⁶ m³/year)"
        legend_title="Size (mm)"
    end
    
    p = plot(
        ylabel=ylabel,
        palette=palette(:vik, num_class_size, rev=true),
        legend_title=legend_title,
        legend=:outerright,
        ylims=(0, 4)
    )
    
    vec_labels = Vector{String}(undef, num_class_size)

    for i in 1:length(vec_labels)

        if i == 1
            vec_labels[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            vec_labels[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            vec_labels[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            vec_labels[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

    end

    reverse!(vec_labels)

    mean_sediment = zeros(Float64, num_class_size, N)

    for i in 1:N
        
        sediment = particle_sediment_volume_each_year(
            area_index[i][1],
            390,
            df_main.tuple[target_df],
            each_year_timing,
            start_year,
            final_year,
            sediment_size,
            :Qsall
        )

        sub_mean_sediment = @view mean_sediment[:, i]
        
        sub_mean_sediment .= vec(Statistics.mean(sediment, dims=1))

        reverse!(sub_mean_sediment)



    end

    StatsPlots.groupedbar!(
        p,
        [area_index[i][2] for i in 1:length(area_index)],
        mean_sediment' ./ 1e6, 
        bar_position=:stack, 
        label=permutedims(vec_labels),
        linecolor=:gray
    )

    return p

end

"""
掃流砂量の年平均値を粒径階別に積み上げたグラフを作る
"""
function make_figure_yearly_mean_particle_bedload_sediment_load_stacked(
        df_main::Main_df,
        target_df::Int,
        num_data_flow::Int,
        each_year_timing::Each_year_timing,
        start_year::Int,
        final_year::Int,
        sediment_size::DataFrame,
        area_index::Vararg{Tuple{Int, <:AbstractString}, N};
        japanese::Bool=false
    ) where {N}

    num_class_size = size(sediment_size, 1)

    if japanese == true
        ylabel="年平均掃流砂量 (10^3 m³/year)"
        legend_title="粒径 (mm)"
    else
        ylabel="Annual average \nbedload (10³ m³/year)"
        legend_title="Size (mm)"
    end
    
    p = plot(
        ylabel=ylabel,
        palette=palette(:vik, num_class_size, rev=true),
        legend_title=legend_title,
        legend=:outerright,
        ylims=(0, 25)
    )
    
    vec_labels = Vector{String}(undef, num_class_size)

    for i in 1:length(vec_labels)

        if i == 1
            vec_labels[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            vec_labels[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            vec_labels[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            vec_labels[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

    end

    reverse!(vec_labels)

    mean_sediment = zeros(Float64, num_class_size, N)

    for i in 1:N
        
        sediment = particle_sediment_volume_each_year(
            area_index[i][1],
            390,
            df_main.tuple[target_df],
            each_year_timing,
            start_year,
            final_year,
            sediment_size,
            :Qball
        )

        sub_mean_sediment = @view mean_sediment[:, i]
        
        sub_mean_sediment .= vec(Statistics.mean(sediment, dims=1))

        reverse!(sub_mean_sediment)

    end

    StatsPlots.groupedbar!(
        p,
        [area_index[i][2] for i in 1:length(area_index)],
        mean_sediment' ./ 1e3, 
        bar_position=:stack, 
        label=permutedims(vec_labels),
        linecolor=:gray
    )

    return p

end

function make_sediment_df!(
    df_sediment,
    area_index,
    data_file,
    each_year_timing::Each_year_timing,
    sediment_size,
    qsall_or_qball_symbol::Symbol
    )

    df_sediment[!, :year] = collect(1965:1999)

    #全粒径階の合計
    sediment = zeros(Float64,1999-1965+1)
    
    sediment_volume_each_year!(
        sediment,
        area_index,
        390,
        data_file,
        each_year_timing,
        qsall_or_qball_symbol,
        1965,
        1999
	)    

    df_sediment[!, :total] = sediment

    #区間に分けた場合
    string_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3)) .* "_mm"
    
    sediment_size_num = size(sediment_size)[1]
    for particle_class_num in 1:sediment_size_num
        sediment = zeros(Float64,1999-1965+1)
        sediment_volume_each_year!(
            sediment,
            area_index,
            390,
            data_file,
            each_year_timing,
            Symbol(
                string(
                    qsall_or_qball_symbol, Printf.@sprintf("%02i", particle_class_num)
                )
            ),
            1965,
            1999
        )
        df_sediment[!, string_sediment_size[particle_class_num]] = sediment
    end

    return df_sediment

end

function make_sediment_df(
    area_index,
    data_file,
    each_year_timing::Each_year_timing,
    sediment_size,
    qsall_or_qball_symbol::Symbol
    )

    df_sediment = DataFrames.DataFrame()

    make_sediment_df!(
        df_sediment,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        qsall_or_qball_symbol
    )
    
    return df_sediment

end

function make_suspended_sediment_per_year_csv(
    area_index,
    data_file,
    each_year_timing::Each_year_timing,
    sediment_size
    )

    df_suspended = DataFrames.DataFrame()

    make_sediment_df!(
        df_suspended,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qsall
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./suspended_sediment_per_year_%03i.csv", area_km),
        df_suspended
    )

end

function make_bedload_sediment_per_year_csv(
    area_index,
    data_file,
    each_year_timing::Each_year_timing,
    sediment_size
    )

    df_bedload = DataFrames.DataFrame()

    make_sediment_df!(
        df_bedload,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qball
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./bedload_sediment_per_year_%03i.csv", area_km),
        df_bedload
    )

end

function make_sediment_mean_year_df!(
    df_sediment_mean_year,
    df_sediment,
    sediment_size,
    name_df
    )

    sediment_size_num = size(sediment_size)[1]

    year_num_index =
        ((1,35), (1,10), (11, 35), (11, 20), (21, 30), (31, 35))
    
    for i in 2:length(name_df)
        for (j, year_i) in enumerate(year_num_index)
   
            df_sediment_mean_year[j, name_df[i]] = Statistics.mean(df_sediment[year_i[1]:year_i[2], i])

        end
    end

    return df_sediment_mean_year

end

function make_suspended_sediment_mean_year_csv(
    area_index,
    data_file,
    each_year_timing::Each_year_timing,
    sediment_size
    )

    df_suspended = DataFrames.DataFrame()

    make_sediment_df!(
        df_suspended,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qsall
    )

    name_df = names(df_suspended)
    
    df_suspended_mean_year = DataFrames.DataFrame(
        year=["1965-1999", "1965-1974", "1975-1999", "1975-1984", "1985-1994", "1995-1999"]
    )

    for i in 2:length(name_df)

        df_suspended_mean_year[!, name_df[i]] .= 0.0
        
    end

    make_sediment_mean_year_df!(
        df_suspended_mean_year,
        df_suspended,
        sediment_size,
        name_df
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./suspended_sediment_mean_year_%03i.csv", area_km),
        df_suspended_mean_year
    )

end

function make_bedload_sediment_mean_year_csv(
    area_index,
    data_file,
    each_year_timing::Each_year_timing,
    sediment_size
    )

    df_bedload = DataFrames.DataFrame()

    make_sediment_df!(
        df_bedload,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qball
    )

    name_df = names(df_bedload)
    
    df_bedload_mean_year = DataFrames.DataFrame(
        year=["1965-1999", "1965-1974", "1975-1999", "1975-1984", "1985-1994", "1995-1999"]
    )

    for i in 2:length(name_df)

        df_bedload_mean_year[!, name_df[i]] .= 0.0
        
    end

    make_sediment_mean_year_df!(
        df_bedload_mean_year,
        df_bedload,
        sediment_size,
        name_df
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./bedload_sediment_mean_year_%03i.csv", area_km),
        df_bedload_mean_year
    )

end

end
