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

module RiverbedGraph

using Plots, DataFrames
import Printf, Statistics, GLM

using ..GeneralGraphModule

import
    ..Main_df,
    ..Each_year_timing,
    ..Exist_riverbed_level,
    ..Measured_cross_rb

include("./sub_riverbed/heatmap_riverbed.jl")

export
    plot_riverbed_elevation_cross_averaged,
    plot_riverbed_elevation_cross_minimum,
    plot_error_riverbed_elevation_cross_averaged,
    plot_error_riverbed_elevation_cross_minimum,
    graph_cumulative_change_in_riverbed,
    graph_condition_change_in_riverbed,    
    observed_riverbed_average_whole_each_year,
    observed_riverbed_average_section_each_year,
    graph_simulated_riverbed_fluctuation,
    graph_variation_per_year_simulated_riverbed_level,
    graph_variation_per_year_mearsured_riverbed_level,    
    graph_variation_per_year_mearsured_riverbed_level_with_linear_model,
    graph_variation_per_year_simulated_riverbed_level_with_linear_model,
    graph_observed_rb_level,
    graph_observed_rb_gradient,
    graph_transverse_distance,
    graph_elevation_gradient_width,
    graph_measured_rb_crossing_1_year_en,
    graph_measured_rb_crossing_several_years,
    graph_simulated_rb_crossing,
    heatmap_measured_cross_rb_elevation,
    heatmap_std_measured_cross_rb_elevation,
    heatmap_std_simulated_cross_rb_elevation,
    heatmap_diff_measured_cross_rb_elevation,
    heatmap_diff_per_year_measured_cross_rb_elevation,
    heatmap_diff_per_year_simulated_cross_rb_elevation,
    heatmap_slope_by_model_measured_cross_rb_elevation,
    heatmap_slope_by_model_simulated_cross_rb_elevation  

#core_comparison_final_average_riverbed_1はタイトルに秒数が入る
function core_comparison_final_average_riverbed_1(
    title_01, data_file, hours_calculate_end, time_schedule)   
    
    distance_from_upstream = data_file[data_file.T .== 0, :I]
    
    seconds_now = 3600 * hours_calculate_end
    
    start_index, finish_index = decide_index_number(hours_calculate_end)
    
    want_title = making_time_series_title(title_01, hours_calculate_end,
                                          seconds_now, time_schedule)
    
    return want_title, distance_from_upstream, start_index, finish_index 
end

#core_comparison_final_average_riverbed_2はタイトルに秒数が入らない
function core_comparison_final_average_riverbed_2(
    title_01, data_file, hours_calculate_end, time_schedule)    
    
    distance_from_upstream = data_file[data_file.T .== 0, :I]
    
    start_index, finish_index = decide_index_number(hours_calculate_end)
    
    want_title = making_time_series_title(title_01, hours_calculate_end, time_schedule)
    
    return want_title, distance_from_upstream, start_index, finish_index
end

function _plot_riverbed_elevation_1(
    when_year::Int,
    want_title::AbstractString,
    japanese::Bool
    )

    if japanese==true
        label_s   = string(when_year, " 実測河床位")
        x_label   = "河口からの距離 (km)"
        y_label   = "標高 (T.P. m)"
    else
        label_s   = string("Measured in ", when_year)
        x_label   = "Distance from the estuary (km)"
        y_label   = "Elevation (T.P. m)"
    end

    p = plot(
        ylabel=y_label,
        xlims=(0,77.8),
        ylims=(-25,90),
	title=want_title,
        xlabel=x_label,
	xticks=[0, 20, 40, 60, 77.8],
        legend=:best,
        xflip=true
    )

    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        primary=:false,
        linestyle=:dash,
        linewidth=1
    )

    return p

end

function _plot_riverbed_elevation_2!(
    p::Plots.Plot,
    df_main::Main_df,
    start_index::Int,
    finish_index::Int,
    symbol_elevation::Symbol,
    distance_from_upstream,
    df_vararg::NTuple{N, Tuple{Int, AbstractString}},
    ::Val{N}
    ) where {N}

    for i in 1:N

        idx          = df_vararg[i][1]
        legend_label = df_vararg[i][2]        
        
        average_riverbed_level= df_main.tuple[idx][start_index:finish_index, symbol_elevation]

        plot!(
            p,
            distance_from_upstream,
            reverse(average_riverbed_level), 
            label=legend_label,
            linecolor=palette(:Set1_9)[i],
            linewidth=1
        )
        
    end

end

function _plot_riverbed_elevation_3!(
    p::Plots.Plot,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    start_index::Int,
    finish_index::Int,
    symbol_elevation::Symbol,
    distance_from_upstream,
    df_vararg::NTuple{N, Tuple{Int, AbstractString}},
    ::Val{N}
    ) where {N}

    for i in 1:N

        idx          = df_vararg[i][1]
        legend_label = df_vararg[i][2]        
        
        average_riverbed_level = df_main.tuple[idx][start_index:finish_index, symbol_elevation]
        max_riverbed_level     = df_max.tuple[idx][start_index:finish_index, symbol_elevation]
        max_riverbed_level     .= max_riverbed_level .- average_riverbed_level
        
        min_riverbed_level     = df_min.tuple[idx][start_index:finish_index, symbol_elevation]
        min_riverbed_level     .= average_riverbed_level .- min_riverbed_level
        
        plot!(
            p,
            distance_from_upstream,
            reverse(average_riverbed_level), 
            label=legend_label,
            linecolor=palette(:Set1_9)[i],
            linewidth=1,
            ribbon=(
                reverse!(min_riverbed_level),
                reverse!(max_riverbed_level)
            ),
            fillcolor=palette(:Set1_9)[i],
            fillalpha=0.3
        )
        
    end

end



"""
実測と再現の断面平均河床位のグラフを作る関数
実測河床位が存在する場合
"""
function plot_riverbed_elevation_cross_averaged(
    df_main::Main_df,
    riverbed_level_data,
    time_schedule,    
    hour_target::Int,
    when_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2(
            "",
            df_main.tuple[begin],
            hour_target,
            time_schedule
        )

    distance_from_upstream .= distance_from_upstream .* 10^-3

    p = _plot_riverbed_elevation_1(
        when_year,
        want_title,
        japanese
    )

    label_s = if japanese==true
        string(when_year, " 実測河床位")
    else
        string("Measured in ", when_year)
    end
    
    plot!(
        p,
        distance_from_upstream,
        reverse(riverbed_level_data[:, Symbol(when_year)]), 
	linecolor=:midnightblue,
        linewidth=1,
        label=label_s
    )

    _plot_riverbed_elevation_2!(
        p,
        df_main,
        start_index,
        finish_index,
        :Zbave,
        distance_from_upstream,
        df_vararg,
        Val(N)
    )    
    
    return p
    
end

"""
実測と再現の断面平均河床位のグラフを作る関数
実測河床位が存在する場合
最大値・最小値ケースのレンジ付き
"""
function plot_riverbed_elevation_cross_averaged(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    riverbed_level_data,
    time_schedule,    
    hour_target::Int,
    when_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2(
            "",
            df_main.tuple[begin],
            hour_target,
            time_schedule
        )

    distance_from_upstream .= distance_from_upstream .* 10^-3

    p = _plot_riverbed_elevation_1(
        when_year,
        want_title,
        japanese
    )

    label_s = if japanese==true
        string(when_year, " 実測河床位")
    else
        string("Measured in ", when_year)
    end
    
    plot!(
        p,
        distance_from_upstream,
        reverse(riverbed_level_data[:, Symbol(when_year)]), 
	linecolor=:midnightblue,
        linewidth=1,
        label=label_s
    )

    _plot_riverbed_elevation_3!(
        p,
        df_main,
        df_max,
        df_min,
        start_index,
        finish_index,
        :Zbave,
        distance_from_upstream,
        df_vararg,
        Val(N)
    )    
    
    return p
    
end


"""
実測と再現の最低河床位のグラフを作る関数
実測河床位が存在する場合
"""
function plot_riverbed_elevation_cross_minimum(
    df_main::Main_df,
    riverbed_level_data,
    time_schedule,    
    hour_target::Int,
    when_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2(
            "",
            df_main.tuple[begin],
            hour_target,
            time_schedule
        )

    distance_from_upstream .= distance_from_upstream .* 10^-3

    p = _plot_riverbed_elevation_1(
        when_year,
        want_title,
        japanese
    )

    label_s = if japanese==true
        string(when_year, " 実測河床位")
    else
        string("Measured in ", when_year)
    end
    
    plot!(
        p,
        distance_from_upstream,
        reverse(riverbed_level_data[:, Symbol(when_year)]), 
	linecolor=:midnightblue,
        linewidth=1,
        label=label_s
    )

    _plot_riverbed_elevation_2!(
        p,
        df_main,
        start_index,
        finish_index,
        :Zbmin,
        distance_from_upstream,
        df_vararg,
        Val(N)
    )    
    
    return p
    
end

"""
実測と再現の最低河床位のグラフを作る関数
実測河床位が存在する場合
最大値・最小値ケースのレンジ付き
"""
function plot_riverbed_elevation_cross_minimum(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    riverbed_level_data,
    time_schedule,    
    hour_target::Int,
    when_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2(
            "",
            df_main.tuple[begin],
            hour_target,
            time_schedule
        )

    distance_from_upstream .= distance_from_upstream .* 10^-3

    p = _plot_riverbed_elevation_1(
        when_year,
        want_title,
        japanese
    )

    label_s = if japanese==true
        string(when_year, " 実測河床位")
    else
        string("Measured in ", when_year)
    end
    
    plot!(
        p,
        distance_from_upstream,
        reverse(riverbed_level_data[:, Symbol(when_year)]), 
	linecolor=:midnightblue,
        linewidth=1,
        label=label_s
    )

    _plot_riverbed_elevation_3!(
        p,
        df_main,
        df_max,
        df_min,
        start_index,
        finish_index,
        :Zbmin,
        distance_from_upstream,
        df_vararg,
        Val(N)
    )    
    
    return p
    
end



#実測と再現の河床位を比較するグラフを作る関数
#実測河床位が存在しない場合
function comparison_final_average_riverbed(
    hours_calculate_end,
    data_file,
    time_schedule,
    japanese::Bool=false
    )

    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2("", data_file,
                                                 hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]

    label_s   = "Simulated"
    x_label   = "Distance from the estuary (km)"
    y_label   = "Elevation (T.P. m)"

    if japanese==true
        label_s   = "再現河床位"
        x_label   = "河口からの距離 (km)"
        y_label   = "標高 (T.P. m)"
    end
    
    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3,
          reverse(average_riverbed_level), 
          label=label_s,  
          ylabel=y_label, xlims=(0,77.8), ylims=(-20,85),
	  title=want_title, xlabel=x_label,
	  xticks=[0, 20, 40, 60, 77.8],
	  linecolor=:orangered,
	  linewidth=2, legend=:topleft)
end

"""
河床標高の誤差をプロットする
断面平均の比較
"""
function plot_error_riverbed_elevation_cross_averaged(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    riverbed_level_data,
    time_schedule,
    hour_target::Int,
    when_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}
    
    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2(
            "",
            df_main.tuple[begin],
            hour_target,
            time_schedule
        )

    distance_from_upstream .= distance_from_upstream .* 10^-3    

    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    if japanese==true
        x_label   = "河口からの距離 (km)"
        y_label   = "誤差 (m)"
    else
        x_label   = "Distance from the estuary (km)"
        y_label   = "Error (m)"
    end
    
    p = vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)

    hline!(p, [0], line=:black, label="", linestyle=:dot, linewidth=1)

    plot!(
        p,
        ylabel=y_label,
        xlims=(0,77.8),
        title=want_title,
	xlabel=x_label,
	xticks=[0, 20, 40, 60, 77.8],
        xflip=true,
	legend=:bottomleft,
        ylims=(-13, 13)
    )

    _plot_error_riverbed_elevation_cross!(
        p,
        df_main,
        df_max,
        df_min,
        riverbed_level_data,
        distance_from_upstream,
        start_index,
        finish_index,
        when_year,
        :Zbave,
        df_vararg,
        japanese,
        Val(N)
    )

    return p
end

"""
河床標高の誤差をプロットする
最小値の比較
"""
function plot_error_riverbed_elevation_cross_minimum(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    riverbed_level_data,
    time_schedule,
    hour_target::Int,
    when_year::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}
    
    want_title, distance_from_upstream, start_index, finish_index =
        core_comparison_final_average_riverbed_2(
            "",
            df_main.tuple[begin],
            hour_target,
            time_schedule
        )

    distance_from_upstream .= distance_from_upstream .* 10^-3    

    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    if japanese==true
        x_label   = "河口からの距離 (km)"
        y_label   = "誤差 (m)"
    else
        x_label   = "Distance from the estuary (km)"
        y_label   = "Error (m)"
    end
    
    p = vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)

    hline!(p, [0], line=:black, label="", linestyle=:dot, linewidth=1)

    plot!(
        p,
        ylabel=y_label,
        xlims=(0,77.8),
        title=want_title,
	xlabel=x_label,
	xticks=[0, 20, 40, 60, 77.8],
        xflip=true,
	legend=:bottomleft,
        ylims=(-13, 13)
    )

    _plot_error_riverbed_elevation_cross!(
        p,
        df_main,
        df_max,
        df_min,
        riverbed_level_data,
        distance_from_upstream,
        start_index,
        finish_index,
        when_year,
        :Zbmin,
        df_vararg,
        japanese,
        Val(N)
    )

    return p
end

function _plot_error_riverbed_elevation_cross!(
    p::Plots.Plot,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    riverbed_level_data,
    distance_from_upstream::AbstractVector{<:AbstractFloat},
    start_index::Int,
    finish_index::Int,
    when_year::Int,
    sediment_type::Symbol,
    df_vararg::NTuple{N, Tuple{Int, AbstractString}},
    japanese::Bool,
    ::Val{N}
    ) where {N}

    measured_riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    for i in 1:N

        idx          = df_vararg[i][1]
        legend_label = df_vararg[i][2]        
        
        average_riverbed_level = df_main.tuple[idx][start_index:finish_index, sediment_type]
        average_riverbed_level .= average_riverbed_level .- measured_riverbed_level
        
        max_riverbed_level     = df_max.tuple[idx][start_index:finish_index, sediment_type]
        max_riverbed_level     .= max_riverbed_level .- measured_riverbed_level
        max_riverbed_level     .= max_riverbed_level .- average_riverbed_level
        
        min_riverbed_level     = df_min.tuple[idx][start_index:finish_index, sediment_type]
        min_riverbed_level     .= min_riverbed_level .- measured_riverbed_level
        min_riverbed_level     .= average_riverbed_level .- min_riverbed_level
        
        plot!(
            p,
            distance_from_upstream,
            reverse(average_riverbed_level), 
            label=legend_label,
            linecolor=palette(:Set1_9)[i],
            linewidth=1,
            ribbon=(
                reverse!(min_riverbed_level),
                reverse!(max_riverbed_level)
            ),
            fillcolor=palette(:Set1_9)[i],
            fillalpha=0.3
        )

    end


end


#累積の河床変動量のグラフを作成したい．

#実測値の累積の河床変動量を計算する．
function cumulative_change_in_measured_riverbed_elevation!(
    cumulative_change_measured,
    measured_riverbed::DataFrame,
    start_year::Int,
    final_year::Int
    )
    
    cumulative_change_measured.=measured_riverbed[!, Symbol(final_year)].-
        measured_riverbed[!, Symbol(start_year)]
    
    return cumulative_change_measured
end

function cumulative_change_in_measured_riverbed_elevation(
    measured_riverbed::DataFrame,
    start_year::Int,
    final_year::Int
    )
    
    flow_size=length(measured_riverbed[!, Symbol(final_year)])
    cumulative_change_measured=zeros(
        eltype(measured_riverbed[!, Symbol(final_year)]),
        flow_size
    )
    
    cumulative_change_in_measured_riverbed_elevation!(
        cumulative_change_measured,
        measured_riverbed,start_year,final_year
    )
    
    return cumulative_change_measured 
end

#再現値の累積の河床変動量を計算する．
function cumulative_change_in_simulated_riverbed_elevation!(
    cumulative_change_simulated,
    data_file::DataFrame,
    start_index_1,
    finish_index_1,
    start_index_2,
    finish_index_2
    )

    cumulative_change_simulated.=data_file[start_index_2:finish_index_2, :Zbave].-
        data_file[start_index_1:finish_index_1, :Zbave]
    
    return cumulative_change_simulated    
end

function cumulative_change_in_simulated_riverbed_elevation(
    data_file::DataFrame,
    start_target_hour,
    final_target_hour
    )
    
    start_index_1, finish_index_1 = decide_index_number(start_target_hour)
    start_index_2, finish_index_2 = decide_index_number(final_target_hour)  
    
    flow_size=length(data_file[start_index_2:finish_index_2, :Zbave])
    cumulative_change_simulated=zeros(
        eltype(data_file[start_index_2:finish_index_2, :Zbave]),
        flow_size
    )
    
    cumulative_change_in_simulated_riverbed_elevation!(
        cumulative_change_simulated,
        data_file,
        start_index_1,
        finish_index_1,
        start_index_2,
        finish_index_2
    )
    
    return cumulative_change_simulated 
end

#累積の河床変動量のグラフを作る関数

function _graph_cumulative_change_in_riverbed!(
    p::Plots.Plot,
    df_main::Main_df,    
    X,
    start_target_hour,
    final_target_hour,
    labels::NTuple{N, Tuple{Int, AbstractString}},
    ::Val{N}
    ) where N

    for (i, label_s) in labels

        cumulative_change_simulated=cumulative_change_in_simulated_riverbed_elevation(
            df_main.tuple[i],
            start_target_hour,
            final_target_hour
        )
        
        plot!(
            p,
            X,
            reverse(cumulative_change_simulated),
            label=label_s,
            linewidth=1,
            linecolor=palette(:Set1_9)[i]
        )
        
    end

    return p

end

function graph_cumulative_change_in_riverbed(
    df_main::Main_df,    
    measured_riverbed,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    string_title::String,
    labels::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where N

    flow_size=length(measured_riverbed[!, Symbol(final_year)])

    cumulative_change_measured=cumulative_change_in_measured_riverbed_elevation(
        measured_riverbed,
        start_year,
        final_year
    )
    
    x_label = "Distance from the estuary (km)"
    y_label = "Variation (m)"
    legend_label_0 = "Measured"
    title_s = string(string_title, " ", start_year, "-", final_year)

    if japanese == true
        x_label = "河口からの距離 (km)"
        y_label = "累積変化量 (m)"
        legend_label_0 = "実測値"
    end

    p=plot(
        legend=:topright,
        legend_font_pointsize=10,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-5.5, 5.5),
        ylabel=y_label,
        title=title_s,
        xflip=true
    )
    
    X = [0.2*(i-1) for i in 1:flow_size]

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    
    plot!(
        p,
        X,
        reverse(cumulative_change_measured),
        linecolor=:midnightblue,
        linewidth=1,
        label=legend_label_0
    )
    
    _graph_cumulative_change_in_riverbed!(
        p,
        df_main,        
        X,
        start_target_hour,
        final_target_hour,
        labels,
        Val(N)
    )


    hline!(p, [0], line=:black, label="", linestyle=:dot, linewidth=1)    

    return p
end

# 全区間の実測河床位の年ごとの平均値を出力する関数
function observed_riverbed_average_whole(riverbed_level::DataFrame,when_year::Int)
    
    average_riverbed_whole = Statistics.mean(
        Tables.columntable(riverbed_level[:, :])[Symbol(when_year)]
    )
    
    return average_riverbed_whole
end

# 区間別の実測河床位の年ごとの平均値を出力する関数
function observed_riverbed_average_section(riverbed_level::DataFrame,when_year::Int,
                                           section_index)
    
    #average_riverbed_level_whole = Statistics.mean(
    #    Tables.columntable(riverbed_level[:, :])[Symbol(when_year)]
    #    )
    
    average_riverbed_section = zeros(Float64,length(section_index))
    
    observed_riverbed_average_section!(average_riverbed_section,
                                       riverbed_level,when_year,section_index)

    return average_riverbed_section
end

function observed_riverbed_average_section!(average_riverbed_section,
                                            riverbed_level::DataFrame,when_year::Int,section_index)
    
    for i in 1:length(section_index)
        average_riverbed_section[i]=Statistics.mean(
	    Tables.columntable(riverbed_level[:, :])[Symbol(when_year)][section_index[i][1]:section_index[i][2]]
	)
    end
    
    return average_riverbed_section
end

#毎年の全区間の実測河床位の平均値を出力する関数
function observed_riverbed_average_whole_each_year(
    riverbed_level::DataFrame,exist_riverbed_level_years)
    
    average_riverbed_level_whole_each_year=zeros(Float64, length(exist_riverbed_level_years))

    observed_riverbed_average_whole_each_year!(average_riverbed_level_whole_each_year,
                                               riverbed_level,exist_riverbed_level_years)
    
    return average_riverbed_level_whole_each_year
end

function observed_riverbed_average_whole_each_year!(average_riverbed_level_whole_each_year,
                                                    riverbed_level::DataFrame,exist_riverbed_level_years)
    
    for (index, target_year) in enumerate(exist_riverbed_level_years)
        string_target_year=string(target_year)
        
        average_riverbed_level_whole_each_year[index] =
	    observed_riverbed_average_whole(riverbed_level,string_target_year)
    end
    
    return average_riverbed_level_whole_each_year
end

#毎年の各区間の実測河床位の平均値を出力する関数
function observed_riverbed_average_section_each_year(
    riverbed_level::DataFrame,section_index,exist_riverbed_level_years)
    
    average_riverbed_level_section_each_year =
        zeros(Float64, length(section_index), length(exist_riverbed_level_years))

    observed_riverbed_average_section_each_year!(average_riverbed_level_section_each_year,
                                                 riverbed_level,section_index,exist_riverbed_level_years)
    
    return average_riverbed_level_section_each_year
end

function observed_riverbed_average_section_each_year!(average_riverbed_level_section_each_year,
                                                      riverbed_level::DataFrame,section_index,exist_riverbed_level_years)
    
    for (index, target_year) in enumerate(exist_riverbed_level_years)
        string_target_year=string(target_year)

        average_riverbed_level_section_each_year[:,index] =
	    observed_riverbed_average_section!(
	        average_riverbed_level_section_each_year[:,index],
                riverbed_level,string_target_year,section_index
	    )

    end
    
    return average_riverbed_level_section_each_year
end

#毎年の再現河床位の平均値の変動のグラフを作りたい
function _graph_simulated_riverbed_fluctuation!(
    p::Plots.Plot,
    keys_year,
    measured_riverbed,
    each_year_timing::Each_year_timing,
    df_vararg::NTuple{N, DataFrame}
    ) where {N}
    
    for i in 1:N
        fluc_average_value = zeros(length(keys_year)+1)
        
        start_i, finish_i = decide_index_number(
            each_year_timing.dict[keys_year[1]][1]
        )
        std_average_value = Statistics.mean(df_vararg[i][start_i:finish_i, :Zbave])        

        for (index, year) in enumerate(keys_year)
            start_i, finish_i = decide_index_number(
                each_year_timing.dict[year][1]
            )

            fluc_average_value[index] =
                Statistics.mean(df_vararg[i][start_i:finish_i, :Zbave]) - std_average_value
        end

        start_i, finish_i = decide_index_number(
            each_year_timing.dict[keys_year[end]][2]
        )

        fluc_average_value[length(keys_year)+1] =
            Statistics.mean(df_vararg[i][start_i:finish_i, :Zbave]) - std_average_value
        

        legend_label = string("Case ", i)
        
        plot!(
            p,
            [keys_year; keys_year[end]+1],
            fluc_average_value,
            markershape=:auto,
            label=legend_label
        )
    end

    return p
    
end

function graph_simulated_riverbed_fluctuation(
    measured_riverbed,
    each_year_timing::Each_year_timing,
    df_vararg::Vararg{DataFrame, N};
    japanese=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing.dict)))

    y_label = "Fluctuation (m)"

    if japanese==true
        y_label="河床変動 (m)" 
    end
    
    p = hline([0], line=:black, label="", linestyle=:dot, linewidth=1)
    plot!(
        p,
        ylabel=y_label,
        xlims=(keys_year[begin],keys_year[end]+1),
        ylims=(-0.9, 0.1),
        legend=:right
    )    

    _graph_simulated_riverbed_fluctuation!(
        p,
        keys_year,
        measured_riverbed,
        each_year_timing,
        df_vararg
    ) 
    
    return p
end

function graph_variation_per_year_simulated_riverbed_level(
    df_main::Main_df,
    measured_riverbed,
    exist_riverbed_level::Exist_riverbed_level,
    each_year_timing::Each_year_timing,
    first_area_index::Int,
    final_area_index::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing.dict)))

    if japanese==true
        y_label="河床位 (T.P. m)"
    else
        y_label = "Riverbed Elevation (T.P. m)"        
    end

    p = plot(
        ylabel=y_label,
        xlims=(keys_year[begin],keys_year[end]+1),
        legend=:outerright,
        legend_font_pointsize=10,
        tickfontsize=14
    )

    fluc_average_value_measured = zeros(length(exist_riverbed_level.years))

    for (index, year) in enumerate(exist_riverbed_level.years)

        fluc_average_value_measured[index] = Statistics.mean(
            measured_riverbed[first_area_index:final_area_index, Symbol(year)]
        )

    end

    if japanese == true
        label_measured = "実測"
    else
        label_measured = "Measured"
    end
    
    plot!(
        p,
        exist_riverbed_level.years .+ 0.5,
        fluc_average_value_measured,
        markershape=:rect,
        label=label_measured
    )
    

    base_ylims = 0.0    

    for (i, label_string) in df_vararg
        
        fluc_average_value = zeros(length(keys_year)+1)

        for (index, year) in enumerate(keys_year)

            first_i, final_i = decide_index_number(each_year_timing.dict[year][1])            
            
            fluc_average_value[index] = Statistics.mean(
                df_main.tuple[i][first_i:final_i, :Zbave][first_area_index:final_area_index]
            )

            if index == 1
                base_ylims = fluc_average_value[index]
            end

        end

        first_i, final_i = decide_index_number(each_year_timing.dict[keys_year[end]][2])

        fluc_average_value[end] = Statistics.mean(
            df_main.tuple[i][first_i:final_i, :Zbave][first_area_index:final_area_index]
        )

        i_max = final_i - first_i + 1

        if japanese == true
            title_s = Printf.@sprintf(
                "区間平均 %.1f km - %.1f km",
                0.2*(i_max-final_area_index), 0.2*(i_max-first_area_index)
            )    
        else 
            title_s = Printf.@sprintf(
                "Average for the section %.1f km - %.1f km",
                0.2*(i_max-final_area_index), 0.2*(i_max-first_area_index)
            )
        end
        
        plot!(
            p,
            [keys_year; keys_year[end]+1],
            fluc_average_value,
            markershape=:auto,
            label=label_string,
            title=title_s
        )
        
    end

    vline!(
        p,
        [1975],
        label="",
        linecolor=:black,
        linestyle=:dot,
        linewidth=1
    )
    
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
        ylims=(base_ylims - 1.2, base_ylims + 0.4)
    )

    return p
end

function graph_condition_change_in_riverbed(
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    string_title::String,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    )

    title_s = string(string_title, " ", start_year, "-", final_year)    
    

    if japanese == true
        x_label = "河口からの距離 (km)"
        y_label = "変化量 (m)"
        label_s = [
            "砂利採取と池田ダム (Case 1 - Case 4)",
            "池田ダム (Case 2 - Case 4)",
            "砂利採取 (Case 3 - Case 4)"            
        ]
    else
        x_label = "Distance from the estuary (km)"
        y_label = "Variation (m)"
        label_s = [
            "by gravel mining and the Ikeda Dam (Case 1 - Case 4)",
            "by the Ikeda Dam (Case 2 - Case 4)",
            "by gravel mining (Case 3 - Case 4)"
        ]
    end

    p=plot(
        legend=:best,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xflip=true,
        xlabel=x_label,
        ylims=(-1.2, 1.2),
        ylabel=y_label,
        title=title_s,
        legend_font_pointsize=10
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)    
    hline!(p, [0], line=:black, label="", linestyle=:dot, linewidth=1)

    base_riverbed_diff = cumulative_change_in_simulated_riverbed_elevation(
        df_base,
        start_target_hour,
        final_target_hour
    )

    with_mining_riverbed_diff = cumulative_change_in_simulated_riverbed_elevation(
        df_with_mining,
        start_target_hour,
        final_target_hour
    )

    with_dam_riverbed_diff = cumulative_change_in_simulated_riverbed_elevation(
        df_with_dam,
        start_target_hour,
        final_target_hour
    )

    with_mining_and_dam_riverbed_diff = cumulative_change_in_simulated_riverbed_elevation(
        df_with_mining_and_dam,
        start_target_hour,
        final_target_hour
    )

    change_by_mining         = with_mining_riverbed_diff -
        base_riverbed_diff
    change_by_dam            = with_dam_riverbed_diff    -
        base_riverbed_diff
    change_by_mining_and_dam = with_mining_and_dam_riverbed_diff -
        base_riverbed_diff
    
    X = [0.2*(i-1) for i in 1:length(change_by_dam)]

    plot!(
        p,
        X,
        reverse(change_by_mining_and_dam),
        label=label_s[1],
        linewidth=1,
        linecolor=palette(:Set1_3)[1]
    )
    
    plot!(
        p,
        X,
        reverse(change_by_dam),
        label=label_s[2],
        linewidth=1,
        linecolor=palette(:Set1_3)[2]
    )
    
    plot!(
        p,
        X,
        reverse(change_by_mining),
        label=label_s[3],
        linewidth=1,
        linecolor=palette(:Set1_3)[3]        
    )

    return p
end

# 実測の断面平均河床位を表示する
function graph_observed_rb_level(
    observed_riverbed_level::DataFrame,
    year::Int;
    japanese::Bool=false
    )
    
    X = [0.2*(i-1) for i in 1:size(observed_riverbed_level, 1)]
    
    if japanese == false
        y_label = "Elevation (T.P. m)"
        x_label = "Distance from the estuary (km)"
    else
        y_label = "標高 (T.P. m)"
        x_label = "河口からの距離 (km)"
    end
    
    p=plot(
        xlims=(X[1], X[end]),
        ylims=(-10, 90),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        xflip=true,
        legend=:none
    )
    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    
    plot!(
        p,
        X, 
        reverse(observed_riverbed_level[!, Symbol(year)])
    )
    
    return p

end

#河床位の横断図を作るために，横軸の川幅の値の配列を作る関数を用意する
function river_width_crossing(
    measured_width::DataFrame,
    measured_cross_rb::Dict{Int, DataFrame},
    area_index::Int,
    year::Int
    )

    size_crossing_points = size(measured_cross_rb[year], 1)

    measured_width_crossing = zeros(Float64, size_crossing_points)

    river_width_crossing!(
        measured_width_crossing,
        size_crossing_points,
        measured_width,
        area_index
    )

    return measured_width_crossing

end

# 実測の断面平均河床位の勾配を計算する関数
function observed_riverbed_gradient!(
    riverbed_gradient,
    observed_riverbed_level,
    year
    )
    
    for i in 1:length(riverbed_gradient)
        riverbed_gradient[i]=(observed_riverbed_level[!, Symbol(year)][i]-observed_riverbed_level[!, Symbol(year)][i+1])/200
    end
    
    return riverbed_gradient
end

# 実測の断面平均河床位の勾配のグラフを作成
function graph_observed_rb_gradient(
    observed_riverbed_level::DataFrame,
    year::Int;
    japanese::Bool=false
    )
    
    X1 = [0.2*(i-1) for i in 1:size(observed_riverbed_level, 1)]
    X2 = [0.2*(i-1)+0.1 for i in 1:(size(observed_riverbed_level, 1)-1)]
    
    if japanese == false
        y_label = "Gradient (-)"
        x_label = "Distance from the estuary (km)"
    else
        y_label = "勾配 (-)"
        x_label = "河口からの距離 (km)"
    end
    
    p=plot(
        xlims=(X1[1], X1[end]),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-0.04, 0.04),
        ylabel=y_label,
        legend=:none
    )
    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    
    plot!(
        p,
        X2, 
        reverse(
            observed_riverbed_gradient(
                observed_riverbed_level,
                year
            )
        )
    )
    
    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=1)
    
    return p

end

# 実測の河川の川幅を示すグラフ
function graph_transverse_distance(
    river_width::DataFrame;
    japanese::Bool=false
    )
    
    X = [0.2*(i-1) for i in 1:size(river_width, 1)]
    
    if japanese == false
        y_label = "Width (m)"
        x_label = "Distance from the estuary (km)"
    else
        y_label = "川幅 (m)"
        x_label = "河口からの距離 (km)"
    end
    
    p=plot(
        xlims=(X[1], X[end]),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        xflip=true,
        ylims=(0, 2500),
        ylabel=y_label,
        legend=:none
    )
    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    
    plot!(
        p,
        X, 
        reverse(river_width[!, 2])
    )
    
    return p

end

# 実測の河床位、勾配、川幅を表すグラフ
function graph_elevation_gradient_width(
    observed_riverbed_level::DataFrame,
    river_width::DataFrame,
    year::Int;
    japanese::Bool=false
    )
    
    l = @layout[a; b; c]
    
    p1 = graph_observed_rb_level(
        observed_riverbed_level,
        year;
        japanese=japanese
    )
    
    plot!(
        p1,
        xlabel="",
        title="(a)",
        titlelocation=:left
    )
    
    p2 = graph_observed_rb_gradient(
        observed_riverbed_level,
        year;
        japanese=japanese
    )
    
    plot!(
        p2,
        xlabel="",
        title="(b)",
        titlelocation=:left
    )
    
    p3 = graph_transverse_distance(
        river_width;
        japanese=japanese
    )
    
    plot!(
        p3,
        title="(c)",
        titlelocation=:left
    )
    
    p = plot(
        p1,
        p2,
        p3,
        layout = l,
        size=(600, 500),
        tickfontsize=13,
        guidefontsize=13
    )
    
    return p
    
end

function observed_riverbed_gradient(
    observed_riverbed_level::DataFrame,
    year::Int
    )
    size_flow = size(observed_riverbed_level, 1)
    
    riverbed_gradient = zeros(Float64,size_flow-1)
    
    observed_riverbed_gradient!(riverbed_gradient,observed_riverbed_level,year)
    
    return riverbed_gradient
end

function river_width_crossing!(
    measured_width_crossing,
    size_crossing_points::Int,
    measured_width::DataFrame,
    area_index::Int
    )

    for i in 2:size_crossing_points

        measured_width_crossing[i] =
            measured_width_crossing[i - 1] +
            measured_width[area_index, 2] / (size_crossing_points - 1)

    end

    return measured_width_crossing

end

# 断面の実測河床位1年分を表示させた．
function graph_measured_rb_crossing_1_year_en(
    measured_width::DataFrame,
    measured_cross_rb::Dict{Int, DataFrame},
    exist_riverbed_level_years,
    area_index::Int,
    year::Int
    )

    p = plot(
        river_width_crossing(
            measured_width,
            measured_cross_rb,
            area_index,
            year
        ),
	measured_rb[year][!, Symbol(area_index)],
	legend=:outerright,
        label=year,
        xlabel="Distance from Left Bank (m)",
        ylabel="Elevation (m)",
        title=Printf.@sprintf("%.1f km from the estuary", 0.2*(390 - area_index))
    )

    return p

end

# 断面の実測河床位を複数年重ねて表示させる。
function graph_measured_rb_crossing_several_years(
    measured_width::DataFrame,
    measured_cross_rb::Measured_cross_rb,
    area_index::Int
    )

    years = sort(collect(keys(measured_cross_rb.dict)))

    p = plot(
	legend=:none,
        xlabel="Distance from Left Bank (km)",
        ylabel="Elevation (m)",
        title=Printf.@sprintf("%.1f km from the estuary", 0.2*(390 - area_index)),
        palette=:roma25
    )
    
    for year in years

        X = river_width_crossing(
            measured_width,
            measured_cross_rb.dict,
            area_index,
            year
        ) / 1000
        
        plot!(
            p,
            X,
       	    measured_cross_rb.dict[year][!, Symbol(area_index)],
            linewidth=1
        )

    end

    return p

end

# 断面の再現河床位を表示させる関数を作る．
function graph_simulated_rb_crossing(
    df_cross::DataFrame,
    measured_width::DataFrame,
    measured_cross_rb::Dict{Int, DataFrame},
    time_schedule,
    area_index::Int,
    year::Int,
    time_index::Int
    )

    want_title = making_time_series_title("",
                                          time_index, time_schedule)

    first_i, last_i = decide_index_number(time_index)
    
    target_cross_rb = Matrix(
        df_cross[first_i:last_i, Between(:Zb001, :Zb101)]
    )'

    river_width_x = river_width_crossing(
        measured_width,
        measured_cross_rb,
        area_index,
        year) ./1000

    p = plot(
        river_width_x,
	measured_cross_rb[year][:, Symbol(area_index)],
        legend=:outerright,
	label=string("Measured in ", year),
    	xlabel="Distance from Left Bank (km)",
        ylabel="Elevation (m)",
        title=string(
            Printf.@sprintf("%.1f km from the estuary", 0.2*(390 - area_index)),
	    " ",
            want_title
        ),
        linecolor=:midnightblue,
        legend_font_pointsize=10
    )

    size_crossing_points = size(measured_cross_rb[year], 1)

    vec_cross_rb = Matrix(
        df_cross[
            first_i:last_i,
            Between(
                :Zb001,
                Symbol(Printf.@sprintf("Zb%3i", size_crossing_points))
            )
        ]
    )'[:, area_index]

    plot!(
        p,
        river_width_x,
        vec_cross_rb,
	label="Simulated"
    )

    return p
    
end

function graph_simulated_rb_crossing(
    df_cross::Vector{DataFrame},
    measured_width::DataFrame,
    measured_cross_rb::Dict{Int, DataFrame},
    time_schedule::DataFrame,
    area_index::Int,
    year::Int,
    time_index::Int
    )

    want_title = making_time_series_title("",
                                          time_index, time_schedule)
    first_i, last_i = decide_index_number(time_index)
    target_cross_rb = Matrix(
        df_cross[1][first_i:last_i, Between(:Zb001, :Zb101)]
    )'

    river_width_x = river_width_crossing(
        measured_width,
        measured_cross_rb,
        area_index,
        year) ./1000

    p = plot(
        river_width_x,
	measured_cross_rb[year][:, Symbol(area_index)],
        legend=:outerright,
	label=string("Measured in ", year),
    	xlabel="Distance from Left Bank (km)",
        ylabel="Elevation (m)",
        title=string(
            Printf.@sprintf("%.1f km from the estuary", 0.2*(390 - area_index)),
	    " ",
            want_title
        ),
        linecolor=:midnightblue,
        legend_font_pointsize=10
    )

    size_crossing_points = size(measured_cross_rb[year], 1)

    for i in 1:length(df_cross)
        
        vec_cross_rb = Matrix(
            df_cross[i][
                first_i:last_i,
                Between(
                    :Zb001,
                    Symbol(Printf.@sprintf("Zb%3i", size_crossing_points))
                )
            ]
        )'[:, area_index]

        plot!(
            p,
            river_width_x,
            vec_cross_rb,
	    label=string("Scenario ", i)
	)

    end
    
    return p
    
end

function graph_simulated_rb_crossing(
    df_cross::DataFrame,
    measured_width::DataFrame,
    measured_cross_rb::Dict{Int, DataFrame},
    time_schedule,
    area_index::Int,
    year::Int,
    time_index::Int,
    df::DataFrame
    )

    p = graph_simulated_rb_crossing(
        df_cross,
        measured_width,
        measured_cross_rb,
        time_schedule,
        area_index,
        year,
        time_index
    )

    start_index, finish_index = decide_index_number(time_index)

    water_level = df[start_index:finish_index, :Z][area_index]

    hline!(p, [water_level], label="Water Level", color=:dodgerblue)

    return p
    
end

function calc_std_cross_rb_elevation!(
    std_cross_rb_ele::Matrix{T},
    measured_cross_rb::Measured_cross_rb,
    years::Vector{Int},
    ) where T <: AbstractFloat
    
    for i in 1:size(std_cross_rb_ele, 2)
        
        for j in 1:size(std_cross_rb_ele, 1)
            
            stock_rb_ele = zeros(length(years))

            for (k, year) in enumerate(years)
                
                stock_rb_ele[k] = measured_cross_rb.dict[year][j, i]
                
            end
            
            std_cross_rb_ele[j, i] = Statistics.std(stock_rb_ele)
            
        end
        
    end
    
end

function calc_std_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb
    )

    years = sort(collect(keys(measured_cross_rb.dict)))
    std_cross_rb_ele = zeros(size(measured_cross_rb.dict[years[1]]))
    
    calc_std_cross_rb_elevation!(
        std_cross_rb_ele,
        measured_cross_rb,
        years
    )
    
    return std_cross_rb_ele 
    
end

function diff_measured_cross_rb_elevation!(
    diff_cross_rb_ele::Matrix{T},
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int
    ) where T <: AbstractFloat
    
    for i in 1:size(diff_cross_rb_ele, 2)
        
        for j in 1:size(diff_cross_rb_ele, 1)
            
            diff_cross_rb_ele[j, i] = 
                measured_cross_rb.dict[final_year][j, i] - 
                measured_cross_rb.dict[start_year][j, i]
            
        end
        
    end
    
end

function diff_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int
    )
    
    years = sort(collect(keys(measured_cross_rb.dict)))
    
    if haskey(measured_cross_rb.dict, start_year) && haskey(measured_cross_rb.dict, final_year)
        diff_cross_rb_ele = zeros(size(measured_cross_rb.dict[start_year]))
        
        diff_measured_cross_rb_elevation!(
            diff_cross_rb_ele,
            measured_cross_rb,
            start_year,
            final_year
        )
        
        return diff_cross_rb_ele

    else
        
        error("There is no actual measured river bed elevation for that year.")
        
    end
    
end

function graph_variation_per_year_mearsured_riverbed_level(
    measured_cross_rb::Measured_cross_rb,
    area_index_flow::Int,
    area_index_cross::Int;
    japanese=false
    )

    years = sort(collect(keys(measured_cross_rb.dict)))

    y_label = "Riverbed Elevation (T.P. m)"

    if japanese==true
        y_label="河床位 (T.P. m)" 
        label_measured = "実測"
        title_figure = string("河口から ", round(0.2 * (390 - area_index_flow), digits=1), " km ", "断面 ", area_index_cross)
    else
        y_label = "Riverbed Elevation (T.P. m)"
        label_measured = "Measured"
        title_figure = string(round(0.2 * (390 - area_index_flow), digits=1), " km from the estuary ", "cross-section ", area_index_cross)
    end

    p = plot(
        ylabel=y_label,
        xlims=(years[begin]-1, years[end]+1),
        xticks=1965:5:2000,
        legend=:bottomleft,
        legend_font_pointsize=10,
        tickfontsize=14,
        title=title_figure
    )

    fluc = zeros(length(measured_cross_rb.dict))

    for (index, year) in enumerate(years)

        fluc[index] = 
            measured_cross_rb.dict[year][area_index_cross, area_index_flow]

    end
    
    plot!(
        p,
        years,
        fluc,
        markershape=:rect,
        label=label_measured
    )    

    base_ylims = fluc[1]

    vline!(
        p,
        [1975],
        label="",
        linecolor=:black,
        linestyle=:dot,
        linewidth=1
    )
    
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
        ylims=(base_ylims - 7.6, base_ylims + 4.4)
    )

    return p
    
end

function fit_linear_variation_per_year_mearsured_riverbed_level(
    measured_cross_rb::Measured_cross_rb,
    area_index_flow::Int,
    area_index_cross::Int,
    start_year::Int,
    final_year::Int
    )

    years = Int[]
    fluc = Float64[]
    
    for year in start_year:final_year
        
        if haskey(measured_cross_rb.dict, year)
            push!(years, year)
            push!(fluc,  measured_cross_rb.dict[year][area_index_cross, area_index_flow])
        end
        
    end
    
    fluc_df = DataFrame(years=years, riverbed=fluc)

    rb_model = GLM.lm(GLM.@formula(riverbed ~ years), fluc_df)
    
    return rb_model
    
end

function graph_variation_per_year_mearsured_riverbed_level_with_linear_model(
    measured_cross_rb::Measured_cross_rb,
    area_index_flow::Int,
    area_index_cross::Int;
    japanese=false
    )
    
    function f(
        x,
        intercept,
        slope
        )
        
        y = intercept + slope * x
        
        return y
    end

    p = graph_variation_per_year_mearsured_riverbed_level(
        measured_cross_rb,
        area_index_flow,
        area_index_cross;
        japanese=false
    )
    
    rb_model = fit_linear_variation_per_year_mearsured_riverbed_level(
        measured_cross_rb,
        area_index_flow,
        area_index_cross,
        1965,
        1975
    )
    
    coefs = GLM.coef(rb_model)
    
    years = 1965:1975
    
    plot!(
        p,
        years,
        f.(years, coefs[1], coefs[2]),
        linestyle=:dash,
        label="Before 1975"
    )
    
    rb_model = fit_linear_variation_per_year_mearsured_riverbed_level(
        measured_cross_rb,
        area_index_flow,
        area_index_cross,
        1975,
        1999
    )
    
    coefs = GLM.coef(rb_model)
    
    years = 1975:1999
    
    plot!(
        p,
        years,
        f.(years, coefs[1], coefs[2]),
        linestyle=:dash,
        label="After 1975"
    )
    
    plot!(
        p,
        legend=:outerright
    )
    
    return p
end

function slope_linear_model_measured_cross_rb_elevation!(
    slope_cross_rb_ele::Matrix{T},
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int
    ) where T <: AbstractFloat
    
    if haskey(measured_cross_rb.dict, start_year) && haskey(measured_cross_rb.dict, final_year)
        
        for i in 1:size(slope_cross_rb_ele, 2)
            
            for j in 1:size(slope_cross_rb_ele, 1) 
                
                rb_model_linear = fit_linear_variation_per_year_mearsured_riverbed_level(
                    measured_cross_rb,
                    i,
                    j,
                    start_year,
                    final_year
                )
                
                slope_cross_rb_ele[j, i] = GLM.coef(rb_model_linear)[2]
                
            end
            
        end
        
    else
        
        error("There is no actual measured river bed elevation for that year.")
        
    end
    
end

function slope_linear_model_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int
    )
    
    slope_cross_rb_ele = zeros(size(measured_cross_rb.dict[start_year]))
    
    slope_linear_model_measured_cross_rb_elevation!(
        slope_cross_rb_ele,
        measured_cross_rb,
        start_year,
        final_year
    )
    
    return slope_cross_rb_ele
    
end

function graph_variation_per_year_simulated_riverbed_level(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    area_index_flow::Int,
    area_index_cross::Int,
    n_x::Int;
    japanese=false
    )
    
    
    years = sort(collect(keys(each_year_timing.dict)))
    push!(years, years[end]+1)

    vec_riverbed_level = zeros(Float64, length(years))

    variation_per_year_simulated_riverbed_level!(
        vec_riverbed_level,
        cross_rb,
        each_year_timing,
        area_index_flow,
        area_index_cross,
        n_x,
        years
    )
    
    if japanese==true
        y_label="河床位 (T.P. m)" 
        label_simulated = "再現"
        title_figure = string("河口から ", round(0.2 * (390 - area_index_flow), digits=1), " km ", "断面 ", area_index_cross)
    else
        y_label = "Riverbed Elevation (T.P. m)"
        label_simulated = "Simulated"
        title_figure = string(round(0.2 * (390 - area_index_flow), digits=1), " km from the estuary ", "cross-section ", area_index_cross)
    end
    
    p = plot(
        ylabel=y_label,
        xlims=(years[begin]-1, years[end]+1),
        xticks=1965:5:2000,
        legend=:bottomleft,
        legend_font_pointsize=10,
        tickfontsize=14,
        title=title_figure
    )
    
    
    plot!(
        p,
        years,
        vec_riverbed_level,
        markershape=:rect,
        label=label_simulated
    )
    
    base_ylims = vec_riverbed_level[begin]
    
    vline!(
        p,
        [1975],
        label="",
        linecolor=:black,
        linestyle=:dot,
        linewidth=1
    )
    
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
        ylims=(base_ylims - 7.6, base_ylims + 4.4)
    )
    
    return p
    
end

function variation_per_year_simulated_riverbed_level!(
    vec_riverbed_level::Vector{Float64},
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    area_index_flow::Int,
    area_index_cross::Int,
    n_x::Int,
    years::Vector{Int}
    )

    
    vec_i_first = zeros(Int, length(years))
    
    for (k, year) in enumerate(years[begin:end-1])
        
        vec_i_first[k] = decide_index_number(
            each_year_timing.dict[year][1],
            n_x
        )[1]
        
    end
    
    vec_i_first[end] = decide_index_number(
        each_year_timing.dict[years[end-1]][2],
        n_x
    )[1]
    
    for (k, t) in enumerate(vec_i_first)
        
        vec_riverbed_level[k] = cross_rb[t+area_index_flow-1, Symbol(Printf.@sprintf("Zb%03i", area_index_cross))]                    
        
    end
    
    return vec_riverbed_level
    
end

function variation_per_year_simulated_riverbed_level(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    area_index_flow::Int,
    area_index_cross::Int,
    n_x::Int,
    years::Vector{Int}
    )

    vec_riverbed_level = zeros(Float64, length(years))

    variation_per_year_simulated_riverbed_level!(
        vec_riverbed_level,
        cross_rb,
        each_year_timing,
        area_index_flow,
        area_index_cross,
        n_x,
        years
    )
    
    return vec_riverbed_level
    
end

function fit_linear_variation_per_year_simulated_riverbed_level(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    area_index_flow::Int,
    area_index_cross::Int,
    n_x::Int,
    start_year::Int,
    final_year::Int
    )
    
    years = collect(start_year:final_year+1)
    
    vec_riverbed_level = zeros(Float64, length(years))

    variation_per_year_simulated_riverbed_level!(
        vec_riverbed_level,
        cross_rb,
        each_year_timing,
        area_index_flow,
        area_index_cross,
        n_x,
        years
    )
    
    fluc_df = DataFrame(years=years, riverbed=vec_riverbed_level)

    rb_model = GLM.lm(GLM.@formula(riverbed ~ years), fluc_df)
    
    return rb_model
    
end

function calc_std_simulated_cross_rb_elevation!(
    std_cross_rb_ele,
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    start_year::Int,
    final_year::Int
    )
    
    n_x, n_y = size(std_cross_rb_ele)

    years = Vector{Int}(undef, 0)

    for year in sort(collect(keys(each_year_timing.dict)))
        if start_year <= year && year <= final_year
            push!(years, year)
        end
    end

    if length(years) == 0
        error()
    end
    
    n = length(years) + 1
    
    vec_i_first = zeros(Int, n)
    
    vec_i_first[1] = GeneralGraphModule.decide_index_number(
        each_year_timing.dict[years[1]][1],
        n_x
    )[1]
    
    for (k, year) in enumerate(years)
        
        vec_i_first[k+1] = GeneralGraphModule.decide_index_number(
            each_year_timing.dict[year][2],
            n_x
        )[1]
        
    end
    
    for i in 1:n_y
        
        for j in 1:n_x
            
            temp_std = zeros(Float64, n)
            
            for (k, t) in enumerate(vec_i_first)
                
                temp_std[k] = cross_rb[t+j-1, Symbol(Printf.@sprintf("Zb%03i", i))]                    
                
            end
            
            std_cross_rb_ele[j, i] = Statistics.std(temp_std)
            
        end
        
    end
    
    return std_cross_rb_ele 
    
end

function calc_std_simulated_cross_rb_elevation(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    n_x::Int,
    n_y::Int,
    start_year::Int,
    final_year::Int
    )
    
    std_cross_rb_ele = zeros(Float64, n_x, n_y)
    

    calc_std_simulated_cross_rb_elevation!(
        std_cross_rb_ele,
        cross_rb,
        each_year_timing,
        start_year,
        final_year
    )
    
    return std_cross_rb_ele 
    
end

function graph_variation_per_year_simulated_riverbed_level_with_linear_model(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    area_index_flow::Int,
    area_index_cross::Int,
    n_x::Int,
    start_year::Int,
    final_year::Int,
    mid_year::Int;
    japanese::Bool=false
    )

    function f(
        x,
        intercept,
        slope
        )
        
        y = intercept + slope * x
        
        return y
    end
    
    p = graph_variation_per_year_simulated_riverbed_level(
        cross_rb,
        each_year_timing,
        area_index_flow,
        area_index_cross,
        n_x;
        japanese=japanese
    )
    
    rb_model = fit_linear_variation_per_year_simulated_riverbed_level(
        cross_rb,
        each_year_timing,
        area_index_flow,
        area_index_cross,
        n_x,
        start_year,
        mid_year-1
    )
    
    coefs = GLM.coef(rb_model)
    
    years = start_year:mid_year
    
    plot!(
        p,
        years,
        f.(years, coefs[1], coefs[2]),
        linestyle=:dash,
        label=string("Before ", mid_year)
    )
    
    rb_model = fit_linear_variation_per_year_simulated_riverbed_level(
        cross_rb,
        each_year_timing,
        area_index_flow,
        area_index_cross,
        n_x,
        mid_year,
        final_year
    )
    
    coefs = GLM.coef(rb_model)
    
    years = mid_year:final_year+1
    
    plot!(
        p,
        years,
        f.(years, coefs[1], coefs[2]),
        linestyle=:dash,
        label=string("After ", mid_year)
    )
    
    return p
    
end

"""
上流側の勾配を求める。
上りなら正の値
上流境界ならNaN
"""
function calc_gradient_upstream(
    main_df::Main_df,
    index_df::Int,
    index_area::Int,
    index_hour::Int,
    flow_size::Int
    )

    index_start, index_last = decide_index_number(
        index_hour,
        flow_size
    )

    ret = 0.0

    if (index_area <= 1) || (index_area > flow_size)
        
        ret = NaN
        
    else

        index_area_point_df = index_start - 1 + index_area
        
        elevation_point =
            main_df.tuple[index_df][index_area_point_df,     :Zbmin]

        x_point =
            main_df.tuple[index_df][index_area_point_df,     :I]

        elevation_up =
            main_df.tuple[index_df][index_area_point_df - 1, :Zbmin]

        x_up =
            main_df.tuple[index_df][index_area_point_df - 1, :I]

        ret = (elevation_up - elevation_point) / (x_point - x_up)
        
    end

    return ret

end

"""
下流側の勾配を求める。
下りなら正の値
下流境界ならNaN
"""
function calc_gradient_downstream(
    main_df::Main_df,
    index_df::Int,
    index_area::Int,
    index_hour::Int,
    flow_size::Int
    )

    index_start, index_last = decide_index_number(
        index_hour,
        flow_size
    )

    ret = 0.0

    if (index_area < 1) || (index_area >= flow_size)
        
        ret = NaN
        
    else

        index_area_point_df = index_start - 1 + index_area
        
        elevation_point =
            main_df.tuple[index_df][index_area_point_df,     :Zbmin]

        x_point =
            main_df.tuple[index_df][index_area_point_df,     :I]

        elevation_down =
            main_df.tuple[index_df][index_area_point_df + 1, :Zbmin]

        x_down =
            main_df.tuple[index_df][index_area_point_df + 1, :I]

        ret = (elevation_point - elevation_down) / (x_down - x_point)
        
    end

    return ret

end

"""
特定位置の時系列の上流側の勾配の配列を返す。
"""
function calc_gradient_upstream_time_series(
    main_df::Main_df,
    index_df::Int,
    index_area::Int,
    flow_size::Int
    )
    
    num_data_time_series::Int =
        size(main_df.tuple[index_df], 1) / flow_size

    gradient_up = zeros(num_data_time_series)

    calc_gradient_upstream_time_series!(
        gradient_up,
        main_df,
        index_df,
        index_area,
        flow_size
    )    
    return gradient_up

end

function calc_gradient_upstream_time_series!(
    gradient_up::AbstractVector{<:AbstractFloat},
    main_df::Main_df,
    index_df::Int,
    index_area::Int,
    flow_size::Int
    )
    
    for index_hour in eachindex(gradient_up)
        gradient_up[index_hour] = calc_gradient_upstream(
            main_df,
            index_df,
            index_area,
            index_hour-1,
            flow_size
        )
    end

end

function plot_gradient_upstream_time_series(
    main_df::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::AbstractFloat,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    vec_gradient_up = [
        calc_gradient_upstream_time_series(
            main_df,
            df_vararg[i][1],
            index_area,
            flow_size
        )
        for i in 1:N
    ]

    p = GeneralGraphModule.plot_time_series_general(
        index_area,
        flow_size,
        river_length_km,
        japanese,
        ntuple(
            i -> tuple(vec_gradient_up[i], df_vararg[i][2]),
            Val(N)
        )...
    )

    plot!(
        p,
        ylabel = if japanese
            "上流側 勾配 (-)"
        else
            "Gradient upstream (-)"
        end
    )

    return p

end

function plot_gradient_upstream_time_series_variation(
    main_df::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::AbstractFloat,
    index_base_df::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    vec_gradient_up_base = calc_gradient_upstream_time_series(
        main_df,
        index_base_df,
        index_area,
        flow_size
    )
    
    vec_gradient_up = [
        calc_gradient_upstream_time_series(
            main_df,
            df_vararg[i][1],
            index_area,
            flow_size
        )
        for i in 1:N
    ]

    p = GeneralGraphModule.plot_time_series_variation_general(
        index_area,
        flow_size,
        river_length_km,
        japanese,
        vec_gradient_up_base,
        ntuple(
            i -> tuple(vec_gradient_up[i], df_vararg[i][2]),
            Val(N)
        )...
            )


    plot!(
        p,
        ylims=(-Inf, Inf)
    )

    return p

end


"""
特定位置の時系列の下流側の勾配の配列を返す。
"""
function calc_gradient_downstream_time_series(
    main_df::Main_df,
    index_df::Int,
    index_area::Int,
    flow_size::Int
    )
    
    num_data_time_series::Int =
        size(main_df.tuple[index_df], 1) / flow_size

    gradient_down = zeros(num_data_time_series)

    calc_gradient_downstream_time_series!(
        gradient_down,
        main_df,
        index_df,
        index_area,
        flow_size
    )

    return gradient_down

end

function calc_gradient_downstream_time_series!(
    gradient_down::AbstractVector{<:AbstractFloat},
    main_df::Main_df,
    index_df::Int,
    index_area::Int,
    flow_size::Int
    )
    
    for index_hour in eachindex(gradient_down)
        gradient_down[index_hour] = calc_gradient_downstream(
            main_df,
            index_df,
            index_area,
            index_hour-1,
            flow_size
        )
    end

end

function plot_gradient_downstream_time_series(
    main_df::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::AbstractFloat,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    vec_gradient_down = [
        calc_gradient_downstream_time_series(
            main_df,
            df_vararg[i][1],
            index_area,
            flow_size
        )
        for i in 1:N
    ]

    p = GeneralGraphModule.plot_time_series_general(
        index_area,
        flow_size,
        river_length_km,
        japanese,
        ntuple(
            i -> tuple(vec_gradient_down[i], df_vararg[i][2]),
            Val(N)
        )...
    )

    plot!(
        p,
        ylabel = if japanese
            "下流側 勾配 (-)"
        else
            "Gradient downstream (-)"
        end
    )

    return p

end

function plot_gradient_downstream_time_series_variation(
    main_df::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::AbstractFloat,
    index_base_df::Int,
    df_vararg::Vararg{Tuple{Int, AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    vec_gradient_down_base = calc_gradient_downstream_time_series(
        main_df,
        index_base_df,
        index_area,
        flow_size
    )
    
    vec_gradient_down = [
        calc_gradient_downstream_time_series(
            main_df,
            df_vararg[i][1],
            index_area,
            flow_size
        )
        for i in 1:N
    ]

    p = GeneralGraphModule.plot_time_series_variation_general(
        index_area,
        flow_size,
        river_length_km,
        japanese,
        vec_gradient_down_base,
        ntuple(
            i -> tuple(vec_gradient_down[i], df_vararg[i][2]),
            Val(N)
        )...
            )


    plot!(
        p,
        ylims=(-Inf, Inf)
    )

    return p

end


end
