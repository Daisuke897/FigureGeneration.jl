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

using Printf, Plots, Statistics, DataFrames
using ..GeneralGraphModule

export comparison_final_average_riverbed,
    difference_final_average_riverbed,
    graph_cumulative_change_in_riverbed,
    graph_condition_change_in_riverbed,    
    observed_riverbed_average_whole_each_year,
    observed_riverbed_average_section_each_year,
    graph_simulated_riverbed_fluctuation,
    graph_measured_rb_crossing_1_year_en,
    graph_measured_rb_crossing_several_years,
    graph_simulated_rb_crossing

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

#実測と再現の河床位を比較するグラフを作る関数
#実測河床位が存在する場合
function comparison_final_average_riverbed(
    hours_calculate_end,
    riverbed_level_data,
    data_file,
    time_schedule,
    when_year::Int;
    japanese::Bool=false
    )

    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    label_vec = String["Measured" "Simulated"]
    x_label   = "Distance from the estuary (km)"
    y_label   = "Elevation (T.P. m)"

    if japanese==true
        label_vec = String["実測河床位" "再現河床位"]
        x_label   = "河口からの距離 (km)"
        y_label   = "標高 (T.P. m)"
    end

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3,
        [reverse(riverbed_level), reverse(average_riverbed_level)], 
        label=label_vec,  
        ylabel=y_label, xlims=(0,77.8), ylims=(-20,85),
	title=want_title, xlabel=x_label,
	xticks=[0, 20, 40, 60, 77.8],
	linecolor=[:midnightblue :orangered],
	linewidth=2, legend=:topleft)
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

#実測と再現の河床位の誤差を表示するグラフを作る関数
function difference_final_average_riverbed(
    hours_calculate_end,
    riverbed_level_data,
    data_file,
    time_schedule,
    when_year::Int,
    japanese::Bool=false
    )
    
    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    difference_riverbed = average_riverbed_level .- riverbed_level

    label_s   = "Error in Riverbed Elevation"
    x_label   = "Distance from the estuary (km)"
    y_label   = "Error (m)"

    if japanese==true
        label_s   = "実測河床位との誤差"
        x_label   = "河口からの距離 (km)"
        y_label   = "誤差 (m)"
    end
    
    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    hline!([0], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3, reverse(difference_riverbed), 
        label=label_s,  
        ylabel=y_label, xlims=(0,77.8), title=want_title,
	xlabel=x_label,
	xticks=[0, 20, 40, 60, 77.8],
	linewidth=2, legend=:bottomleft, ylims=(-3,3))
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

## varargを用いて複数条件の作図ができないか試してみる
function _graph_cumulative_change_in_riverbed!(
    p::Plots.Plot,
    X,
    start_target_hour,
    final_target_hour,
    ::Val{N},
    df_vararg::NTuple{N, T}    
    ) where {T, N}

    for i in 1:N

        cumulative_change_simulated=cumulative_change_in_simulated_riverbed_elevation(
            df_vararg[i],
            start_target_hour,
            final_target_hour
        )

        legend_label = string("Case ", i)
        
        plot!(
            p,
            X,
            reverse(cumulative_change_simulated),
            label=legend_label
        )
        
    end

    return p

end

function graph_cumulative_change_in_riverbed(
    measured_riverbed,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_tuple::NTuple{N, T};
    japanese::Bool=false
    ) where {T, N}

    flow_size=length(measured_riverbed[!, Symbol(final_year)])

    cumulative_change_measured=cumulative_change_in_measured_riverbed_elevation(
        measured_riverbed,
        start_year,
        final_year
    )
    
    x_label = "Distance from the estuary (km)"
    y_label = "Cumulative Change (m)"
    legend_label_0 = "Measured"
    title_s = string(start_year, "-", final_year)

    if japanese == true
        x_label = "河口からの距離 (km)"
        y_label = "累積変化量 (m)"
        legend_label_0 = "実測値"
    end

    p=plot(
        legend=:outerright,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-3, 3),
        ylabel=y_label,
        title=title_s
    )
    
    X = [0.2*(i-1) for i in 1:flow_size]

    plot!(
        p,
        X,
        reverse(cumulative_change_measured),
        linecolor=:midnightblue,
        label=legend_label_0
    )
    
    _graph_cumulative_change_in_riverbed!(
        p,
        X,
        start_target_hour,
        final_target_hour,
        Val(N),
        df_tuple
    )


    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)



    
    return p
end

function graph_cumulative_change_in_riverbed(
    measured_riverbed,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{T, N};
    japanese::Bool=false
    ) where {T, N}

    p = graph_cumulative_change_in_riverbed(
        measured_riverbed,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vararg,
        japanese=japanese
    )
    
    return p
end

# 全区間の実測河床位の年ごとの平均値を出力する関数
function observed_riverbed_average_whole(riverbed_level::DataFrame,when_year::Int)
    
    average_riverbed_whole = mean(
        Tables.columntable(riverbed_level[:, :])[Symbol(when_year)]
        )
	
    return average_riverbed_whole
end

# 区間別の実測河床位の年ごとの平均値を出力する関数
function observed_riverbed_average_section(riverbed_level::DataFrame,when_year::Int,
    section_index)
    
    #average_riverbed_level_whole = mean(
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
        average_riverbed_section[i]=mean(
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
    each_year_timing,
    df_vararg::NTuple{N, DataFrame}
    ) where {N}
    
    for i in 1:N
        fluc_average_value = zeros(length(keys_year)+1)
        
        start_i, finish_i = decide_index_number(
            each_year_timing[keys_year[1]][1]
        )
        std_average_value = mean(df_vararg[i][start_i:finish_i, :Zbave])        

        for (index, year) in enumerate(keys_year)
            start_i, finish_i = decide_index_number(
                each_year_timing[year][1]
            )

            fluc_average_value[index] =
                mean(df_vararg[i][start_i:finish_i, :Zbave]) - std_average_value
        end

        start_i, finish_i = decide_index_number(
            each_year_timing[keys_year[end]][2]
        )

        fluc_average_value[length(keys_year)+1] =
            mean(df_vararg[i][start_i:finish_i, :Zbave]) - std_average_value
        

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
    each_year_timing,
    df_vararg::Vararg{DataFrame, N};
    japanese=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing)))

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

function graph_condition_change_in_riverbed(
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
    y_label = "Variation (m)"
    title_s = string("Riverbed Elevation ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]

    if japanese == true
        x_label = "河口からの距離 (km)"
        y_label = "変化量 (m)"
        title_s = string("断面平均河床位 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:best,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-2, 2),
        ylabel=y_label,
        title=title_s
    )
    
    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=3)

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
        title=@sprintf("%.1f km from the estuary", 0.2*(390 - area_index))
    )

    return p

end

# 断面の実測河床位を複数年重ねて表示させる。
function graph_measured_rb_crossing_several_years(
    measured_width::DataFrame,
    measured_cross_rb::Dict{Int, DataFrame},
    area_index::Int
    )

    years = sort(collect(keys(measured_cross_rb)))

    p = plot(
	    legend=:none,
        xlabel="Distance from Left Bank (km)",
        ylabel="Elevation (m)",
        title=@sprintf("%.1f km from the estuary", 0.2*(390 - area_index)),
        palette=cgrad(:brg, length(years), categorical = true)
    )
    
    for year in years

        X = river_width_crossing(
            measured_width,
            measured_cross_rb,
            area_index,
            year
        ) / 1000
        
        plot!(
            p,
            X,
       	    measured_cross_rb[year][!, Symbol(area_index)],
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

    target_cross_rb = Matrix(
                          df_cross[df_cross.T .== 3600 * time_index, Between(:Zb001, :Zb101)]
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
            @sprintf("%.1f km from the estuary", 0.2*(390 - area_index)),
	        " ",
            want_title
        ),
        linecolor=:midnightblue
	)

    size_crossing_points = size(measured_cross_rb[year], 1)

    vec_cross_rb = Matrix(
        df_cross[
            df_cross.T .== 3600 * time_index,
            Between(
                :Zb001,
                Symbol(@sprintf("Zb%3i", size_crossing_points))
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


end
