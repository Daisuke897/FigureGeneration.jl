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

module GeneralGraphModule

using DataFrames

import ..Each_year_timing,
    ..Plots,
    ..Main_df

export decide_index_number,
    making_time_series_title

#時間に対応するインデックス数を返す関数
function decide_index_number(target_hour::Int)
    start_index = 1 + 390*target_hour
    finish_index = start_index + 389
    
    return start_index, finish_index
end

function decide_index_number(
    target_hour::Int,
    num_data_flow::Int
    )
    start_index = 1 + num_data_flow*target_hour
    finish_index = start_index + (num_data_flow-1)
    
    return start_index, finish_index
end


#時刻の情報を入力して，時刻の入ったグラフのタイトルを作成する関数
#秒の値も入れるバージョン
function making_time_series_title(title_01, hours_now, seconds_now, time_schedule)
    at_t = " at t = " 
    unit_title = " s  "
    unit_hour = ":00 JST"    
    
    year = time_schedule[hours_now+1, :year]
    month = time_schedule[hours_now+1, :month]
    day = time_schedule[hours_now+1, :day]
    hour = time_schedule[hours_now+1, :hour]
    
    want_title = string(title_01, at_t, seconds_now,
                        unit_title, hour, unit_hour, "  ", month, "/", day, "/", year, " ")
    
    return want_title
end

#時刻の情報を入力して，時刻の入ったグラフのタイトルを作成する関数
#秒の値は入れないバージョン
function making_time_series_title(title_01, hours_now, time_schedule)
    unit_hour = ":00 JST"    
    
    year = time_schedule[hours_now+1, :year]
    month = time_schedule[hours_now+1, :month]
    day = time_schedule[hours_now+1, :day]
    hour = time_schedule[hours_now+1, :hour]
    
    want_title = string(title_01, hour, unit_hour,
                        "  ", month, "/", day, "/", year, " ")
    
    return want_title
end

function _get_target_year_sec!(
    target_year_sec,
    each_year_timing::Each_year_timing
    )
    
    for i in 1:length(each_year_timing.dict)
        target_year = 1965 + i - 1
        target_year_sec[i] = 3600 * each_year_timing.dict[target_year][1]
    end

end

function _vline_per_year_timing!(
    p,
    each_year_timing::Each_year_timing
    )

    target_year_sec=zeros(
        Int, length(each_year_timing.dict)
    )

    _get_target_year_sec!(
        target_year_sec,
        each_year_timing
    )
    
    vline!(p,
           target_year_sec,
           label="",
           linecolor=:black,
           linestyle=:dash,
           linewidth=1
           )

    return p
end

"""
特定位置における時系列の変化を示す配列を出力する。
"""
function make_array_time_series_change(
    df::DataFrames.DataFrame,
    index_area::Int,
    flow_size::Int,
    symbol_target::Symbol
    )

    num_data_time_series::Int = size(df, 1) / flow_size

    data_time_series = zeros(
        num_data_time_series
    )

    make_array_time_series_change!(
        data_time_series,
        df,
        index_area,
        flow_size,
        symbol_target
    )

    return data_time_series

end

function make_array_time_series_change!(
    data_time_series::AbstractArray{<:AbstractFloat},
    df::DataFrames.DataFrame,
    index_area::Int,
    flow_size::Int,
    symbol_target::Symbol
    )


    for i in eachindex(data_time_series)

        i_first, _ = decide_index_number(
            i-1,
            flow_size
        )

        idx = i_first - 1 + index_area

        data_time_series[i] = df[idx, symbol_target]

    end

end

function plot_time_series_general(
    df_main::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::Float64,
    symbol_target::Symbol,
    japanese::Bool,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N}
    ) where {N}

    num_data_time_series::Int = size(df_main.tuple[begin], 1) / flow_size

    p =  _plot_time_series_variation_general(
        index_area,
        river_length_km,
        num_data_time_series,
        japanese
    )
    
    range_time_series = range(
        start = 0,
        stop  = num_data_time_series - 1
    )

    data_time_series = zeros(
        num_data_time_series
    )

    for i in 1:N

        idx_df       = df_vararg[i][1]
        legend_label = df_vararg[i][2]

        make_array_time_series_change!(
            data_time_series,
            df_main.tuple[idx_df],
            index_area,
            flow_size,
            symbol_target
        )
        
        Plots.plot!(
            p,
            range_time_series,
            data_time_series,
            label=legend_label,
            linewidth=1,
            linecolor=Plots.palette(:Set1_9)[idx_df]            
        )

    end

    return p

end

function plot_time_series_variation_general(
    df_main::Main_df,
    index_area::Int,
    flow_size::Int,
    river_length_km::Float64,
    symbol_target::Symbol,
    japanese::Bool,
    index_df_base::Int,
    df_vararg::Vararg{Tuple{Int, <:AbstractString}, N}
    ) where {N}


    num_data_time_series::Int = size(df_main.tuple[begin], 1) / flow_size

    p =  _plot_time_series_variation_general(
        index_area,
        river_length_km,
        num_data_time_series,
        japanese
    )

    if japanese == true
        y_label="変動量 (%)"
    else
        y_label="Variation (%)"
    end

    Plots.plot!(
        p,
        ylabel=y_label,
        ylims =(-50, 50)
    )

    Plots.hline!(
        [0],
        linestyle=:dash,
        linecolor=:black,
        linewidth=1,
        primary=:false
    )

    range_time_series = range(
        start = 0,
        stop  = num_data_time_series - 1
    )
    
    data_time_series_base = 
        make_array_time_series_change(
            df_main.tuple[index_df_base],
            index_area,
            flow_size,
            symbol_target
        )

    data_time_series = zeros(
        num_data_time_series
    )

    for i in 1:N

        idx_df       = df_vararg[i][1]
        legend_label = df_vararg[i][2]

        make_array_time_series_change!(
            data_time_series,
            df_main.tuple[idx_df],
            index_area,
            flow_size,
            symbol_target
        )

        data_time_series .=
            (data_time_series ./ data_time_series_base .- 1.0) * 100
        
        Plots.plot!(
            p,
            range_time_series,
            data_time_series,
            label=legend_label,
            linewidth=1,
            linecolor=Plots.palette(:Set1_9)[i]            
        )

    end

    return p

end

function _plot_time_series_variation_general(
    index_area::Int,
    river_length_km::Float64,
    num_data_time_series::Int,
    japanese::Bool
    )

    area_km = abs(river_length_km - 0.2 * (index_area - 1))

    if japanese == true

        x_label="時間"
        l_title=string("河口から ", round(area_km, digits=2), " km")

    else

        x_label="Hours"
        l_title=string(
            "At ",
            round(area_km, digits=2),
            " km from the estuary"
        )

    end

    p = Plots.plot(
        xlims=(0, num_data_time_series - 1),
        xlabel=x_label,
        legend_title=l_title,
        legend=:best,
        legend_font_pointsize=10,
        legend_title_font_pointsize=11
    )

    return p

end


end
