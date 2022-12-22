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

module Hydraulic_conditions

using Printf,
      Plots,
      Statistics,
      DataFrames,
      ..GeneralGraphModule

export make_upstream_discharge_graph_ja,
    make_downstream_water_level_graph_ja,
    make_up_discharge_down_water_lev_graph_ja

#条件としての上流の流量の作図
function make_upstream_discharge_graph_ja(
    data_file,
    time_schedule,
    target_hours
    )

    time_data = unique(data_file[:, :T])
    discharge_data = time_schedule[:, :discharge_m3_s]

    p = plot(
        time_data,
        discharge_data,
        legend=:none,
        xlabel="秒数(s)",
        xlims=(0,maximum(time_data)),
        xticks=[0, 4e6, 8e6, 12e6],
        ylabel="流量(m³/s)",
        ylims=(0,10000),
        linestyle=:dot,
        linecolor=:black
    )
    
    plot!(
        p,
        time_data[1:(target_hours+1)],
        discharge_data[1:(target_hours+1)],
        linecolor=:red
    )

    return p

end

function make_upstream_discharge_graph_ja(
    data_file,
    time_schedule,
    each_year_timing,
    target_hours
    )

    time_data = unique(data_file[:, :T])
    discharge_data = time_schedule[:, :discharge_m3_s]

    target_year_sec=zeros(
        Int, length(each_year_timing)-1
    )

    for i in 1:length(each_year_timing)-1
        target_year = 1965 + i - 1
        target_year_sec[i] = 3600 * each_year_timing[target_year][1]
    end

    p = vline(
            target_year_sec,
            label="",
            linecolor=:black,
            linestyle=:dash,
            linewidth=1
         )
    
    plot!(p,
        time_data,
        discharge_data,
        legend=:none,
        xlabel="秒数(s)",
        xlims=(0,maximum(time_data)),
        xticks=[0, 4e6, 8e6, 12e6],
        ylabel="流量(m³/s)",
        ylims=(0,10000),
        linestyle=:dot,
        linecolor=:black
    )
    
    plot!(
        p,
        time_data[1:(target_hours+1)],
        discharge_data[1:(target_hours+1)],
        linecolor=:red
    )

    return p

end

#条件としての河口の水位の作図

function make_downstream_water_level_graph_ja(
    data_file,
    time_schedule,
    target_hours
    )

    time_data = unique(data_file[:, :T])
    water_level_data = time_schedule[:, :water_level_m]

    p = plot(
        time_data,
        water_level_data,
        legend=:none,
        xlabel="秒数(s)",
        xlims=(0,maximum(time_data)),
        xticks=[0, 4e6, 8e6, 12e6],
        ylabel="水位(m)",
        #ylims=(0,10000),
        linestyle=:dot,
        linecolor=:black
    )
    
    plot!(
        p,
        time_data[1:(target_hours+1)],
        water_level_data[1:(target_hours+1)],
        linecolor=:midnightblue
    )

    return p

end

# 2つ並べた図を作りたい
function make_up_discharge_down_water_lev_graph_ja(
    data_file,
    time_schedule,
    target_hours
    )

    p1 = make_upstream_discharge_graph_ja(
        data_file,
        time_schedule,
        target_hours
    )

    plot!(p1, xlabel="")

    p2 = make_downstream_water_level_graph_ja(
        data_file,
        time_schedule,
        target_hours
    )

    plot!(p1, p2, layout=Plots.@layout[a;b])

end   


end
