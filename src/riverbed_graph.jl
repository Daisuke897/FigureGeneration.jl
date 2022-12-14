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

export comparison_final_average_riverbed_ja,
    comparison_final_average_riverbed_en,
    difference_final_average_riverbed_ja,
    difference_final_average_riverbed_en,
    graph_cumulative_change_in_riverbed_ja,
    graph_cumulative_change_in_riverbed_en,
    observed_riverbed_average_whole_each_year,
    observed_riverbed_average_section_each_year,
    graph_measured_rb_crossing_1_year_en,
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

#実測と再現の河床位を比較するグラフを作る関数（日本語版）
#実測河床位が存在する場合
function comparison_final_average_riverbed_ja(
    hours_calculate_end,riverbed_level_data,
    data_file,time_schedule,when_year::Int)

    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3,
        [reverse(riverbed_level), reverse(average_riverbed_level)], 
        label=["実測河床位" "再現河床位"],  
        ylabel="標高 (T.P. m)", xlims=(0,77.8), ylims=(-20,85),
	title=want_title, xlabel="河口からの距離 (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linecolor=[:midnightblue :orangered],
	linewidth=2, legend=:topleft)
end

#実測と再現の河床位を比較するグラフを作る関数（英語版）
#実測河床位が存在する場合
function comparison_final_average_riverbed_en(
    hours_calculate_end,riverbed_level_data,
    data_file,time_schedule,when_year::Int)

    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3,
        [reverse(riverbed_level), reverse(average_riverbed_level)], 
        label=["Measured" "Simulated"],  
        ylabel="Elevation (T.P. m)", xlims=(0,77.8), ylims=(-20,85),
	title=want_title, xlabel="Distance from the estuary (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linecolor=[:midnightblue :orangered],
	linewidth=2, legend=:topleft)
end

#実測と再現の河床位を比較するグラフを作る関数（日本語版）
#実測河床位が存在しない場合
function comparison_final_average_riverbed_ja(
    hours_calculate_end,
    data_file,time_schedule)

    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3,
        reverse(average_riverbed_level), 
        label="再現河床位",  
        ylabel="標高 (T.P. m)", xlims=(0,77.8), ylims=(-20,85),
	title=want_title, xlabel="河口からの距離 (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linecolor=:orangered,
	linewidth=2, legend=:topleft)
end

#実測と再現の河床位を比較するグラフを作る関数（英語版）
#実測河床位が存在しない場合
function comparison_final_average_riverbed_en(
    hours_calculate_end,
    data_file,time_schedule)

    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    
    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3,
        reverse(average_riverbed_level), 
        label="Simulated",  
        ylabel="Elevation (T.P. m)", xlims=(0,77.8), ylims=(-20,85),
	title=want_title, xlabel="Distance from the estuary (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linecolor=:orangered,
	linewidth=2, legend=:topleft)
end

#実測と再現の河床位の誤差を表示するグラフを作る関数（日本語版）
function difference_final_average_riverbed_ja(
    hours_calculate_end, riverbed_level_data,
    data_file, time_schedule, when_year::Int)
    
    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    difference_riverbed = average_riverbed_level .- riverbed_level

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    hline!([0], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3, reverse(difference_riverbed), 
        label="実測河床位との誤差",  
        ylabel="誤差 (m)", xlims=(0,77.8), title=want_title,
	xlabel="河口からの距離 (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linewidth=2, legend=:bottomleft, ylims=(-3,3))
end

#実測と再現の河床位の誤差を表示するグラフを作る関数（英語版）
function difference_final_average_riverbed_en(
    hours_calculate_end, riverbed_level_data,
    data_file, time_schedule, when_year::Int)
    
    want_title, distance_from_upstream, start_index, finish_index =
    core_comparison_final_average_riverbed_2("", data_file,
    hours_calculate_end, time_schedule)

    average_riverbed_level = data_file[start_index:finish_index, :Zbave]
    riverbed_level = riverbed_level_data[:, Symbol(when_year)]

    difference_riverbed = average_riverbed_level .- riverbed_level

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    hline!([0], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(distance_from_upstream.*10^-3, reverse(difference_riverbed), 
        label="Difference in Riverbed Elevation",  
        ylabel="Difference (m)", xlims=(0,77.8), title=want_title,
	xlabel="Distance from the estuary (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linewidth=2, legend=:bottomleft, ylims=(-3,3))
end

#累積の河床変動量のグラフを作成したい．

#実測値の累積の河床変動量を計算する．
function cumulative_change_in_measured_riverbed_elevation!(cumulative_change_measured,
    measured_riverbed,start_year::Int,final_year::Int)
    
    cumulative_change_measured.=measured_riverbed[:, Symbol(final_year)].-
        measured_riverbed[:, Symbol(start_year)]
    
    return cumulative_change_measured
end
function cumulative_change_in_measured_riverbed_elevation(measured_riverbed,
    start_year::Int,final_year::Int)
    
    flow_size=length(measured_riverbed[:, Symbol(final_year)])
    cumulative_change_measured=zeros(Float64, flow_size)
    
    cumulative_change_in_measured_riverbed_elevation!(cumulative_change_measured,
        measured_riverbed,start_year,final_year)
    
    return cumulative_change_measured 
end

#再現値の累積の河床変動量を計算する．
function cumulative_change_in_simulated_riverbed_elevation!(cumulative_change_simulated,
    data_file,start_index_1,finish_index_1,start_index_2,finish_index_2)

    cumulative_change_simulated.=data_file[start_index_2:finish_index_2, :Zbave].-
        data_file[start_index_1:finish_index_1, :Zbave]
    
    return cumulative_change_simulated    
end
function cumulative_change_in_simulated_riverbed_elevation(data_file,start_target_hour,
    final_target_hour)
    
    start_index_1, finish_index_1 = decide_index_number(start_target_hour)
    start_index_2, finish_index_2 = decide_index_number(final_target_hour)  
        
    flow_size=length(data_file[start_index_2:finish_index_2, :Zbave])
    cumulative_change_simulated=zeros(Float64, flow_size)
    
    cumulative_change_in_simulated_riverbed_elevation!(cumulative_change_simulated,
        data_file,start_index_1,finish_index_1,start_index_2,finish_index_2)
    
    return cumulative_change_simulated 
end

#累積の河床変動量のグラフを作る関数（日本語版）
function graph_cumulative_change_in_riverbed_ja(measured_riverbed,data_file_1,
    start_year::Int,final_year::Int,start_target_hour,final_target_hour)
    
    flow_size=length(measured_riverbed[:, Symbol(final_year)])
    cumulative_change_measured=zeros(Float64, flow_size)
    cumulative_change_simulated_1=zeros(Float64, flow_size)    
    
    start_index_1, finish_index_1 = decide_index_number(start_target_hour)
    start_index_2, finish_index_2 = decide_index_number(final_target_hour)
    
    cumulative_change_in_measured_riverbed_elevation!(cumulative_change_measured,
        measured_riverbed,start_year,final_year)
    
    cumulative_change_in_simulated_riverbed_elevation!(cumulative_change_simulated_1,
        data_file_1,start_index_1,finish_index_1,start_index_2,finish_index_2)
	
    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    hline!([0], line=:black, label="", linestyle=:dash, linewidth=3)
    
    plot!([0.2*(i-1) for i in 1:flow_size],
        [reverse(cumulative_change_measured), reverse(cumulative_change_simulated_1)],
        legend=:topleft, xlims=(0,77.8), linewidth=2,
        ylims=(-3,3), linecolor=[:midnightblue :orangered],
	xticks=[0, 20, 40, 60, 77.8],
        xlabel="河口からの距離 (km)", ylabel="累積変化量 (m)",
        label=["実測河床位" "再現河床位"])
end

#累積の河床変動量のグラフを作る関数（英語版）
function graph_cumulative_change_in_riverbed_en(measured_riverbed,data_file_1,
    start_year::Int,final_year::Int,start_target_hour,final_target_hour)
    
    flow_size=length(measured_riverbed[:, Symbol(final_year)])
    cumulative_change_measured=zeros(Float64, flow_size)
    cumulative_change_simulated_1=zeros(Float64, flow_size)    
    
    start_index_1, finish_index_1 = decide_index_number(start_target_hour)
    start_index_2, finish_index_2 = decide_index_number(final_target_hour)
    
    cumulative_change_in_measured_riverbed_elevation!(cumulative_change_measured,
        measured_riverbed,start_year,final_year)
    
    cumulative_change_in_simulated_riverbed_elevation!(cumulative_change_simulated_1,
        data_file_1,start_index_1,finish_index_1,start_index_2,finish_index_2)
	
    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    hline!([0], line=:black, label="", linestyle=:dash, linewidth=3)
    
    plot!([0.2*(i-1) for i in 1:flow_size],
        [reverse(cumulative_change_measured), reverse(cumulative_change_simulated_1)],
        legend=:topleft, xlims=(0,77.8), linewidth=2,
        ylims=(-3,3), linecolor=[:midnightblue :orangered],
	xticks=[0, 20, 40, 60, 77.8],
        xlabel="Distance from the estuary (km)", ylabel="Cumulative Change (m)",
        label=["Measured" "Simulated"])
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

#毎年の各区間の実測河床位の平均値の変動のグラフを作る関数
#function observed_riverbed_average_graph_ja()


#end

#河床位の横断図を作るために，横軸の川幅の値の配列を作る関数を用意する
function river_width_crossing(
    measured_width::DataFrame,
    measured_rb::Vector{DataFrame},
    longitudinal_index::Int,
    year_index::Int
    )

    size_crossing_points = size(measured_rb[year_index])[1]

    measured_width_crossing = zeros(Float64, size_crossing_points)

    river_width_crossing!(
        measured_width_crossing,
        size_crossing_points,measured_width,
        longitudinal_index
	)

    return measured_width_crossing

end

function river_width_crossing!(
    measured_width_crossing,
    size_crossing_points,
    measured_width::DataFrame,
    longitudinal_index::Int
    )

    for i = 2:size_crossing_points

        measured_width_crossing[i] =
            measured_width_crossing[i - 1] +
            measured_width[longitudinal_index, 1] / (size_crossing_points - 1)

    end

    return measured_width_crossing

end

# 断面の実測河床位1年分を表示させた．
function graph_measured_rb_crossing_1_year_en(
    measured_width, measured_rb,
    exist_riverbed_level_years,
    longitudinal_index::Int,
    year_index::Int
    )

    plot(
        river_width_crossing(measured_width,measured_rb,longitudinal_index,year_index),
	measured_rb[year_index][:, Symbol(longitudinal_index)],
	legend=:outerright, label=string(exist_riverbed_level_years[year_index]),
        xlabel="Distance from Left Bank (m)",
        ylabel="Elevation (m)",
        title=@sprintf("%.1f km from the estuary", 0.2*(390 - longitudinal_index))
    )

end

# 断面の実測河床位3年分（1965年, 1975年, 1999年）を表示させた．
#function graph_measured_rb_crossing_3_years(
#           measured_width,
#           measured_rb,
#           longitudinal_index::Int
#           )

#           plot(river_width_crossing(measured_width,measured_rb,longitudinal_index,22),
#              [measured_rb[1][:, Symbol(longitudinal_index)], measured_rb[6][:, Symbol(longitudinal_index)],
#              measured_rb[22][:, Symbol(longitudinal_index)]],
#              legend=:outerright, label=["1965" "1975" "1999"],
#              xlabel="Distance from Left Bank (m)",
#              ylabel="Elevation (m)",
#              title=@sprintf("%.1f km from the estuary", 0.2*(390 - longitudinal_index)))
#           end

# 断面の再現河床位を表示させる関数を作る．
function graph_simulated_rb_crossing(
    df_cross,
    measured_width, measured_rb,
    exist_riverbed_level_years,
    time_schedule,
    longitudinal_index::Int,
    year_index::Int,
    time_index::Int
    )

    want_title = making_time_series_title("",
        time_index, time_schedule)

    target_cross_rb = Matrix(
                          df_cross[df_cross.T .== 3600 * time_index, Between(:Zb001, :Zb101)]
			  )'

    plot(river_width_crossing(measured_width,measured_rb,longitudinal_index,year_index),
	measured_rb[year_index][:, Symbol(longitudinal_index)],
	legend=:top,
	label=string("Measured in ", exist_riverbed_level_years[year_index]),
	xlabel="Distance from Left Bank (m)",
        ylabel="Elevation (m)",
        title=string(@sprintf("%.1f km from the estuary", 0.2*(390 - longitudinal_index)),
	    " ", want_title)
	)

    plot!(river_width_crossing(measured_width,measured_rb,longitudinal_index,year_index),
        target_cross_rb[:, longitudinal_index],
	label="Simulated"
	)
	
end

end