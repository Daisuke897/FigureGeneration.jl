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

module ParticleSize

using Printf, Plots, Statistics, DataFrames
using LinearAlgebra
using ..GeneralGraphModule

import ..Main_df, ..Each_year_timing

export
    graph_ratio_simulated_particle_size_dist,
    plot_average_simulated_particle_size_dist,
    plot_average_simulated_particle_size_yearly_mean,
    graph_average_simulated_particle_size_fluc,
    graph_cumulative_change_in_mean_diameter,
    graph_cumulative_ratio_in_mean_diameter,
    graph_cumulative_rate_in_mean_diameter,
    graph_cumulative_rate_variation_in_mean_diameter,
    graph_condition_change_in_mean_diameter,
    graph_condition_ratio_in_mean_diameter,
    graph_cumulative_condition_change_in_mean_diameter,
    graph_cumulative_condition_rate_in_mean_diameter,
    graph_measured_distribution

#河床の粒度分布を計算する関数
function simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    hours_now::Int
    )

    start_index, finish_index = decide_index_number(hours_now)

    num_particle_size        = size(sediment_size, 1)
    string_num_particle_size = @sprintf("%02i", num_particle_size)

    simulated_particle_size_dist = Matrix(
                                       data_file[start_index:finish_index,
                                       Between("fmc01", string("fmc", string_num_particle_size))]
                                       )

    simulated_particle_size_dist!(simulated_particle_size_dist)

    return simulated_particle_size_dist
end

function simulated_particle_size_dist!(simulated_particle_size_dist)

    reverse!(simulated_particle_size_dist, dims=2)

    cumsum!(
        simulated_particle_size_dist,
        simulated_particle_size_dist,
	dims=2
	)
	
    reverse!(simulated_particle_size_dist, dims=2)

    return simulated_particle_size_dist
end

function get_average_simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    hours_now::Int
    )

    start_index, finish_index = decide_index_number(hours_now)

    num_particle_size        = size(sediment_size, 1)
    string_num_particle_size = @sprintf("%02i", num_particle_size)

    simulated_particle_dist =
        Matrix(
            data_file[start_index:finish_index,
                      Between(
                          "fmc01",
                          string("fmc", string_num_particle_size)
                      )]
        )

    average_simulated_particle_size_dist =
        get_average_simulated_particle_size_dist(
            simulated_particle_dist,
            sediment_size
        )

    return average_simulated_particle_size_dist
end

function get_average_simulated_particle_size_dist(
    simulated_particle_size_dist::Matrix{T},
    sediment_size::DataFrame
    ) where {T}

    average_simulated_particle_size_dist =
        zeros(
            T,
            size(simulated_particle_size_dist, 1)
        )

    get_average_simulated_particle_size_dist!(
        average_simulated_particle_size_dist,
        simulated_particle_size_dist,
        sediment_size[!, 3]
    )
    
    return average_simulated_particle_size_dist
end

function get_average_simulated_particle_size_dist!(
    average_simulated_particle_size_dist::Vector{T},
    simulated_particle_size_dist::Matrix{T},    
    sediment_size_vec::Vector{T}
    ) where {T}
    
    average_simulated_particle_size_dist .=
        simulated_particle_size_dist * sediment_size_vec
    
end

# 縦軸に割合(%)，横軸に河口からの距離(km)とした，
# グラフを作る．
function graph_ratio_simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    time_schedule::DataFrame,
    hours_now::Int;
    japanese::Bool=false
    )

    start_index, finish_index = decide_index_number(hours_now)

    num_particle_size        = size(sediment_size, 1)
    string_num_particle_size = @sprintf("%02i", num_particle_size)

    simulated_particle_size_dist = Matrix(
                                       data_file[start_index:finish_index,
                                       Between("fmc01", "fmc$string_num_particle_size")]
                                       )

    simulated_particle_size_dist!(simulated_particle_size_dist)

    distance_from_estuary = 0:0.2:77.8

    simulated_particle_size_dist = simulated_particle_size_dist * 100

    want_title = making_time_series_title("",
        hours_now, time_schedule)

    x_label="Distance from the estuary (km)"
    y_label="Percentage (%)"
    l_title="Size (mm)"

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="割合 (%)"
        l_title="粒径 (mm)"
    end        
    
    p = plot(
            palette=:tab20, title=want_title,
	    # xticks=[0, 20, 40, 60, 77.8],
            xlabel=x_label,
	    ylabel=y_label,
	    xlims=(0,77.8), ylims=(0, 100),
	    legend=:outerright,
	    legend_title=l_title,
	    top_margin=10Plots.mm
	    )

    for i in 1:num_particle_size

        plot!(
	    p,
	    distance_from_estuary,
	    reverse(simulated_particle_size_dist[:, i]),
	    fillrange=0, linewidth=1,
	    label = round(sediment_size[i, 3]; sigdigits=3)
	    )

    end

    vline!([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    hline!([50], line=:black, label="", linestyle=:dash, linewidth=2)

    return p
end

"""
特定時刻における平均粒径の縦断分布
初期値なし
"""
function plot_average_simulated_particle_size_dist(
    df_main::Main_df,    
    sediment_size::DataFrame,
    time_schedule::DataFrame,
    target_hour::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}
    
    X = df_main.tuple[begin][1:flow_size, :I] ./ 1000

    p = _plot_average_simulated_particle_size_dist(
        time_schedule,
        target_hour,
        japanese
    )

    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    _plot_average_simulated_particle_size_dist!(
        p,
        df_main,
        target_hour,
        X,
        df_vararg,
        flow_size,
        Val(N)
    )
    
    return p
end

"""
特定時刻における平均粒径の縦断分布
初期値あり
"""
function plot_average_simulated_particle_size_dist(
    df_main::Main_df,    
    sediment_size::DataFrame,
    time_schedule::DataFrame,
    target_hour::Int,
    label_initial::AbstractString,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}
    
    X = df_main.tuple[begin][1:flow_size, :I] ./ 1000

    p = _plot_average_simulated_particle_size_dist(
        time_schedule,
        target_hour,
        japanese
    )

    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    initial_simulated_particle_size_dist =
        df_main.tuple[begin][1:flow_size, :Dmave] * 1000
    
    plot!(
        p,
        X,
        reverse(initial_simulated_particle_size_dist),
        label=label_initial,
        linecolor=:midnightblue,
        linewidth=1
    )    
    
    _plot_average_simulated_particle_size_dist!(
        p,
        df_main,
        target_hour,
        X,
        df_vararg,
        flow_size,
        Val(N)
    )
    
    return p
end

function _plot_average_simulated_particle_size_dist(
    time_schedule::DataFrame,
    hours_now::Int,
    japanese::Bool
    )

    want_title = making_time_series_title("",
        hours_now, time_schedule)

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="平均粒径 (mm)"
    else
        x_label="Distance from the estuary (km)"
        y_label="Mean diameter (mm)"
    end        

    p = plot(
        title=want_title,
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        xlims=(0,77.8),
        ylims=(-10, 200),
        legend=:topleft,
        legend_font_pointsize=10,
        xflip=true
    )

    return p
end

function _plot_average_simulated_particle_size_dist!(
    p::Plots.Plot,
    df_main::Main_df,
    target_hour::Int,
    X::AbstractArray{<:AbstractFloat},
    df_vararg::NTuple{N, Tuple{Int, AbstractString}},
    flow_size::Int,
    ::Val{N}
    ) where {N}

    start_index, finish_index = decide_index_number(
        target_hour,
        flow_size
    )    

    for i in 1:N

        idx_df       = df_vararg[i][1]
        legend_label = df_vararg[i][2]

        simu_particle_size_dist =
            df_main.tuple[idx_df][start_index:finish_index, :Dmave] * 1000

        plot!(
            p,
            X,
            reverse(simu_particle_size_dist),
            label=legend_label,
            linewidth=1,
            linecolor=palette(:Set1_9)[i]
        )
        
    end

    return p
end

"""
特定年の平均粒径の平均値を求める
"""
function calc_average_simulated_particle_size_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year::Int,
    flow_size::Int
    )

    average_simulated_particle_size_yearly_mean =
        Statistics.mean(
            idx -> df[idx[1]:idx[2], :Dmave],
            decide_index_number.(
                range(start = each_year_timing.dict[year][1],
                      stop  = each_year_timing.dict[year][2]),
                flow_size
            )
        )

    return average_simulated_particle_size_yearly_mean

end

"""
複数年の平均粒径の平均値を求める
"""
function calc_average_simulated_particle_size_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    flow_size::Int
    )

    average_simulated_particle_size_yearly_mean =
        Statistics.mean(
            target_year ->
                calc_average_simulated_particle_size_yearly_mean(
                    df,
                    each_year_timing,
                    target_year,
                    flow_size
                ),
            range(start = year_first,
                  stop = year_last)
        )

    return average_simulated_particle_size_yearly_mean

end

"""
複数年の平均粒径の平均値のグラフを作成する。
初期値なし
"""
function plot_average_simulated_particle_size_yearly_mean(
    df_main::Main_df,    
    sediment_size::DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false
    ) where {N}

    X = df_main.tuple[begin][1:flow_size, :I] ./ 1000

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="平均粒径 (mm)"
    else
        x_label="Distance from the estuary (km)"
        y_label="Mean diameter (mm)"
    end        

    legend_title_year = string(
        year_first,
        " - ",
        year_last
    )
    
    p = plot(
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        xlims=(0,77.8),
        ylims=(-10, 200),
        legend=:topleft,
        legend_title=legend_title_year,
        legend_font_pointsize=10,
        legend_title_font_pointsize=11,
        xflip=true
    )

    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    for i in 1:N

        idx_df       = df_vararg[i][1]
        legend_label = df_vararg[i][2]

        simu_particle_size_dist =
            calc_average_simulated_particle_size_yearly_mean(
                df_main.tuple[idx_df],
                each_year_timing,
                year_first,
                year_last,
                flow_size
            ) * 1000       

        plot!(
            p,
            X,
            reverse(simu_particle_size_dist),
            label=legend_label,
            linewidth=1,
            linecolor=palette(:Set1_9)[i]
        )
        
    end

    return p

end


#平均粒径の時系列的な変化を示すグラフを作りたい
function graph_temporal_variation_average_simulated_particle_size_fluc(
    df_main::Main_df,
    target_df::Int,
    time_schedule::DataFrame,
    title::String,
    target_hour::Vararg{Int, N};
    japanese::Bool=false
    ) where {N}


    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="平均粒径 (mm)"
    else
        x_label="Distance from the estuary (km)"
        y_label="Mean diameter (mm)"
    end        

    line_colors = cgrad(:reds, N, categorical = true)
    
    p = plot(
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        xlims=(0,77.8),
        ylims=(-10, 200),
        legend=:topleft,
        legend_font_pointsize=10,
        title=title
    )

    distance_from_estuary = 0:0.2:77.8

    for i in 1:N

        start_index, finish_index = decide_index_number(target_hour[i])
        
        simu_particle_size_dist = df_main.tuple[target_df][start_index:finish_index, :Dmave] * 1000
    
        legend_label = making_time_series_title(
            "",
            target_hour[i],
            time_schedule
        )
            
        plot!(
            p, distance_from_estuary,
            reverse(simu_particle_size_dist),
            label=legend_label,
            linewidth=1,
            linecolor=line_colors[i]
        )

    end
    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=1)

    return p

end

function _graph_average_simulated_particle_size_fluc!(
    p::Plots.Plot,
    keys_year,
    sediment_size,
    each_year_timing::Each_year_timing,
    i_begin::Int,
    i_end::Int,
    df_vararg::NTuple{N, DataFrame};
    japanese::Bool=false
    ) where {N}

    base_ylims = 0.0

    for i in 1:N
        
        fluc_average_value = zeros(length(keys_year)+1)

        for (index, year) in enumerate(keys_year)
            average_simulated_particle_size_dist =
                get_average_simulated_particle_size_dist(
                    df_vararg[i],
                    sediment_size,
                    each_year_timing.dict[year][1]
                )

            fluc_average_value[index] =
                mean(average_simulated_particle_size_dist[i_begin:i_end])
            if index == 1
                base_ylims = fluc_average_value[index]
            end
            
        end

        average_simulated_particle_size_dist =
            get_average_simulated_particle_size_dist(
                df_vararg[i],
                sediment_size,
                each_year_timing.dict[keys_year[end]][2]
            )

        fluc_average_value[end] =
            mean(average_simulated_particle_size_dist[i_begin:i_end])

        i_max = length(average_simulated_particle_size_dist)

        legend_label = string("Case ", i)

        if japanese == true
            title_s = @sprintf(
                "区間平均 %.1f km - %.1f km",
                0.2*(i_max-i_end),
                0.2*(i_max-i_begin)
            )
        else
            title_s = @sprintf(
                "Average for the section %.1f km - %.1f km",
                0.2*(i_max-i_end),
                0.2*(i_max-i_begin)
            )
        end
        
        plot!(
            p,
            [keys_year; keys_year[end]+1],
            fluc_average_value,
            markershape=:auto,
            label=legend_label,
            title=title_s
        )
        
    end

    hline!(
        p,
        [base_ylims],
        label="",
        linecolor=:black,
        linestyle=:dash,
        linewidth=1
    )

    plot!(
        p,
        ylims=(max(base_ylims - 35, 0), base_ylims + 2)
    )

    return p
end

function _graph_average_simulated_particle_size_fluc(
    keys_year,
    japanese::Bool
    )

    y_label="Mean Diameter (mm)"

    if japanese==true
        y_label="平均粒径 (mm)"
    end        

    p = vline(
        [1975],
        line=:black,
        label="",
        linestyle=:dot,
        linewidth=1
    )
    
    plot!(
        p,
        ylabel=y_label,
        xlims=(keys_year[begin], keys_year[end]+1),
        legend=:outerright,
        legend_font_pointsize=10,
        tickfontsize=14
    )

    return p
end

function graph_average_simulated_particle_size_fluc(
    sediment_size,
    each_year_timing::Each_year_timing,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing.dict)))
    
    p = _graph_average_simulated_particle_size_fluc(
        keys_year,
        japanese
    )
    
    _graph_average_simulated_particle_size_fluc!(
        p,
        keys_year,
        sediment_size,
        each_year_timing,
        df_vararg
    )

    return p
end

function graph_average_simulated_particle_size_fluc(
    sediment_size,
    each_year_timing::Each_year_timing,
    i_begin::Int,
    i_end::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing.dict)))
    
    p = _graph_average_simulated_particle_size_fluc(
        keys_year,
        japanese
    )

    _graph_average_simulated_particle_size_fluc!(
        p,
        keys_year,
        sediment_size,
        each_year_timing,
        i_begin,
        i_end,
        df_vararg,
        japanese=japanese
    )

    return p
end

#変動率を求める（1965年〜1974年と1975年〜1999年）
function calc_change_rate_in_mean_diameter(
    df_main::Main_df,
    target_df_base::Int,
    target_df::Int,
    target_hour::Int
    )

    start_index, finish_index = decide_index_number(target_hour)
    
    mean_diameter_base = df_main.tuple[target_df_base      ][start_index:finish_index, :Dmave] * 1000
    mean_diameter      = df_main.tuple[target_df           ][start_index:finish_index, :Dmave] * 1000

    change_rate = (mean_diameter ./ mean_diameter_base .- 1.0) * 100

    return change_rate

end

function graph_change_rate_in_mean_diameter(
    df_main::Main_df,
    target_df_base::Int,
    target_df_mining_dam::Int,
    target_df_dam::Int,
    target_df_mining::Int,
    time_schedule::DataFrame,
    target_hour::Int;
    japanese::Bool=false
    )

    want_title = making_time_series_title(
        "",
        target_hour,
        time_schedule
    )
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化率 (%)"
    else
        x_label="Distance from the estuary (km)"
        y_label="Rate of variation (%)"
    end

    p = plot(
        title=want_title,
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        xlims=(0,77.8),
        yticks=[-80, -60, -40, -20, 0, 20, 40, 60, 80],
        ylims=(-85, 85),
        legend=:best,
        legend_font_pointsize=11,
        titlefontsize=16,
        xflip=true
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    hline!(p, [0], line=:black, label="", linestyle=:dot, linewidth=1)
    
    distance_from_estuary = 0:0.2:77.8

    change_rate_mining_dam = calc_change_rate_in_mean_diameter(
        df_main,
        target_df_base,
        target_df_mining_dam,
        target_hour
    )

    change_rate_dam = calc_change_rate_in_mean_diameter(
        df_main,
        target_df_base,
        target_df_dam,
        target_hour
    )

    change_rate_mining = calc_change_rate_in_mean_diameter(
        df_main,
        target_df_base,
        target_df_mining,
        target_hour
    )
    
    plot!(
        p,
        distance_from_estuary,
        reverse(change_rate_mining_dam),
        label="by gravel mining and the Ikeda Dam (Case 1 - Case 4)",
        linecolor=palette(:Set1_3)[1],
        linewidth=1
    )

    plot!(
        p,
        distance_from_estuary,
        reverse(change_rate_dam),
        label="by the Ikeda Dam (Case 2 - Case 4)",
        linecolor=palette(:Set1_3)[2],
        linewidth=1
    )

    plot!(
        p,
        distance_from_estuary,
        reverse(change_rate_mining),
        label="by gravel mining (Case 3 - Case 4)",
        linecolor=palette(:Set1_3)[3],
        linewidth=1
    )

    return p

end

function graph_cumulative_change_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    x_label = "Distance from the estuary (km)"
    y_label="Cumulative variation (mm)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="累積変化量 (mm)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
    end

    p=plot(
        legend=:bottomleft,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-150, 100),
        ylabel=y_label,
        title=title_s
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    for i in 1:N

        cum_change_simu_particle_size =
            _average_simulated_particle_size_diff(
                df_vararg[i],
                sediment_size,
                start_target_hour,
                final_target_hour
            )

        legend_label = string("Case ", i)

        X = [0.2*(i-1) for i in 1:length(cum_change_simu_particle_size)]
        
        plot!(
            p,
            X,
            reverse(cum_change_simu_particle_size),
            label=legend_label
        )

    end

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)        

    return p
    
end

function graph_cumulative_condition_change_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vector;
    japanese::Bool=false
    )
    
    l = @layout[a; b]
    
    p1 = graph_cumulative_change_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[], ylims=(-150, 100))
    
    p2 = graph_condition_change_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p2, title="", legend=:bottomright, ylims=(-40, 40))
    
    p = plot(
        p1,
        p2,
        layout=l,
        tickfontsize=11,
        guidefontsize=11,
        legend_font_pointsize=7
    )
    
    return p
    
end

function graph_cumulative_ratio_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    x_label = "Distance from the estuary (km)"
    y_label="Ratio (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="比率 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
    end

    p=plot(
        legend=:topleft,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    

    for i in 1:N

        ratio_simu_particle_size =
            _average_simulated_particle_size_ratio(
                df_vararg[i],
                sediment_size,
                start_target_hour,
                final_target_hour
            )

        legend_label = string("Case ", i)

        X = [0.2*(i-1) for i in 1:length(ratio_simu_particle_size)]
        
        plot!(
            p,
            X,
            reverse(ratio_simu_particle_size),
            label=legend_label
        )

    end

    return p
    
end

function graph_cumulative_rate_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    x_label = "Distance from the estuary (km)"
    y_label="Rate (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化率 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
    end

    p=plot(
        legend=:top,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s,
        ylims=(-2,40)
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    for i in 1:N

        rate_simu_particle_size =
            _average_simulated_particle_size_ratio(
                df_vararg[i],
                sediment_size,
                start_target_hour,
                final_target_hour
            ) .- 1

        legend_label = string("Case ", i)

        X = [0.2*(i-1) for i in 1:length(rate_simu_particle_size)]
        
        plot!(
            p,
            X,
            reverse(rate_simu_particle_size),
            label=legend_label
        )

    end

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    

    return p
    
end

function graph_cumulative_rate_variation_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    ) 

    x_label = "Distance from the estuary (km)"
    y_label="Variation (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化量 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:bottom,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s,
        ylims=(-2,2)
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    base_mean_particle =
        _average_simulated_particle_size_ratio(
            df_base,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1

    with_mining_mean_particle =
        _average_simulated_particle_size_ratio(
            df_with_mining,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1
        
    with_dam_mean_particle =
        _average_simulated_particle_size_ratio(
            df_with_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1

    with_mining_and_dam_mean_particle =
        _average_simulated_particle_size_ratio(
            df_with_mining_and_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1
    
    change_by_mining         = with_mining_mean_particle -
        base_mean_particle
    change_by_dam            = with_dam_mean_particle -
        base_mean_particle
    change_by_mining_and_dam = with_mining_and_dam_mean_particle -
        base_mean_particle

    X = [0.2*(i-1) for i in 1:length(change_by_dam)]
        
    plot!(
        p,
        X,
        reverse(change_by_mining),
        label=label_s[1]
    )

    plot!(
        p,
        X,
        reverse(change_by_dam),
        label=label_s[2]
    )
    
    plot!(
        p,
        X,
        reverse(change_by_mining_and_dam),
        label=label_s[3]
    )
    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    

    return p
    
end

function graph_cumulative_condition_rate_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vector;
    japanese::Bool=false
    )
    
    l = @layout[a; b]
    
    p1 = graph_cumulative_rate_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[])
    
    p2 = graph_cumulative_rate_variation_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p2, title="")
    
    p = plot(
        p1,
        p2,
        layout=l,
        tickfontsize=11,
        guidefontsize=11,
        legend_font_pointsize=8
    )
    
    return p
    
end

function graph_condition_change_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    )

    x_label = "Distance from the estuary (km)"
    y_label = "Variation (mm)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化量 (mm)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:bottomright,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-15, 15),
        ylabel=y_label,
        title=title_s
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)

    base_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_base,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_and_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining_and_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )
    
    change_by_mining         = with_mining_mean_particle_diff -
        base_mean_particle_diff
    change_by_dam            = with_dam_mean_particle_diff    -
        base_mean_particle_diff
    change_by_mining_and_dam = with_mining_and_dam_mean_particle_diff -
        base_mean_particle_diff
    
    X = [0.2*(i-1) for i in 1:length(change_by_dam)]
        
    plot!(
        p,
        X,
        reverse(change_by_mining),
        label=label_s[1]
    )

    plot!(
        p,
        X,
        reverse(change_by_dam),
        label=label_s[2]
    )
    
    plot!(
        p,
        X,
        reverse(change_by_mining_and_dam),
        label=label_s[3]
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    
    return p

end

function graph_condition_ratio_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    )

    x_label = "Distance from the estuary (km)"
    y_label = "Ratio (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="比率 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:bottomright,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    
    base_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_base,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_and_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining_and_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )
    
    change_by_mining         = with_mining_mean_particle_diff ./
        base_mean_particle_diff
    change_by_dam            = with_dam_mean_particle_diff    ./
        base_mean_particle_diff
    change_by_mining_and_dam = with_mining_and_dam_mean_particle_diff ./
        base_mean_particle_diff
    
    X = [0.2*(i-1) for i in 1:length(base_mean_particle_diff)]
        
    plot!(
        p,
        X,
        reverse(change_by_mining),
        label=label_s[1]
    )

    plot!(
        p,
        X,
        reverse(change_by_dam),
        label=label_s[2]
    )
    
    plot!(
        p,
        X,
        reverse(change_by_mining_and_dam),
        label=label_s[3]
    )

    return p

end

function _average_simulated_particle_size_diff(
    df::DataFrame,
    sediment_size::DataFrame,
    start_target_hour::Int,
    final_target_hour::Int
    )

    mean_particle_start =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            start_target_hour
        )

    mean_particle_final =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            final_target_hour
        )
    
    mean_particle_diff =
        mean_particle_final - mean_particle_start

    return mean_particle_diff

end

function _average_simulated_particle_size_ratio(
    df::DataFrame,
    sediment_size::DataFrame,
    start_target_hour::Int,
    final_target_hour::Int
    )

    mean_particle_start =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            start_target_hour
        )

    mean_particle_final =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            final_target_hour
        )
    
    mean_particle_ratio =
        mean_particle_final ./ mean_particle_start

    return mean_particle_ratio

end

function graph_measured_distribution(
        fmini::DataFrame,
        sediment_size::DataFrame,
        distance_km::Vector{Int},
        max_area_index::Int;
        japanese::Bool=false
    )
    
    if japanese == true 
        x_label  = "粒径 (mm)" 
        y_label  = "累積 (%)"
        t_legend = "河口からの\n距離 (km)"
    else
        x_label  = "Particle size (mm)"
        y_label  = "Cumulative volume (%)"
        t_legend = "Distance from\nthe estuary\n(km)"
    end
    
    p = plot(
        legend=:outerright,
        ylims=(0, 100),
        ylabel=y_label,
        xlims=(0.01, 1000),
        xlabel=x_label,
        xscale=:log10,
        label_title=t_legend
    )
    
    num_class_size = size(sediment_size, 1)
    
    for km in distance_km
    
        area_index = max_area_index - 5 * km
        
        cum_vol = cumsum(
            [i for i in fmini[area_index, 2:(1+num_class_size)]]
        ) * 100
        
        plot!(
            p,
            sediment_size[!, 3],
            cum_vol,
            label=km,
            markershape=:auto,
            markersize=5
        )
        
    end
    
    return p
    
end

# 初期粒度分布の積み上げのグラフ
function graph_longutitude_measured_particle_distribution(
        fmini::DataFrame,
        sediment_size::DataFrame,
        df_main::Main_df;
        japanese::Bool=false
    )
    
    num_class_size = size(sediment_size, 1)
    flow_size = length(df_main.tuple[1][df_main.tuple[1].T .== 0, :I])
    
    X = [0.2*(i-1) for i in 1:flow_size]
    
    if japanese == true 
        x_label  = "河口からの距離 (km)" 
        y_label  = "割合 (%)"
        t_legend = "粒径 (mm)"
    else
        x_label  = "Distance from the estuary (km)"
        y_label  = "Percentage (%)"
        t_legend = "Size (mm)"
    end
    
    long_measured_particle_dist = zeros(Float64, size(fmini[!, 2:(1+num_class_size)]))

    cumsum!(                                    
        long_measured_particle_dist,
        Matrix(fmini[:, 2:(1+num_class_size)]),
        dims=2                                     
    )                                          

    reverse!(
        long_measured_particle_dist,
        dims=1
    )
    
    p = plot(
        legend=:outerright,
        ylims=(0, 100),
        ylabel=y_label,
        xlims=(0, X[end]),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        xflip=true,
        label_title=t_legend,
        palette=palette(:vik, num_class_size+2, rev=true),
        legend_title_font_pointsize=10,
        legend_font_pointsize=10
    )
    
    hline!([0], label="", linecolor=:black)
    
    digits_n = [3,2,2,2,2,2,2,1,1,1,1,0,0]
    
    for i in reverse(1:num_class_size)
        
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
            long_measured_particle_dist[:, i] * 100,
            fillrange=0,
            linewidth=1,
            label=s_label
            #round(sediment_size[i, 3]; sigdigits=3)
        )
        
    end
    
    plot!(p, bottommargin=3.0Plots.mm)
    
    vline!([40.2,24.4,14.6], label="", linestyle=:dash, linewidth=1, linecolor=:black)
    
    return p
    
end


end
