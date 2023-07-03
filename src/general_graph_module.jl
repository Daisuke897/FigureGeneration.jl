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

using Plots

export decide_index_number
export making_time_series_title

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
    each_year_timing
    )
    
    for i in 1:length(each_year_timing)
        target_year = 1965 + i - 1
        target_year_sec[i] = 3600 * each_year_timing[target_year][1]
    end

end

function _vline_per_year_timing!(
    p,
    each_year_timing
    )

    target_year_sec=zeros(
        Int, length(each_year_timing)
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

end
