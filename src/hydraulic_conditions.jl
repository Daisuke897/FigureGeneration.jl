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

export make_upstream_discharge_graph,
    make_downstream_water_level_graph,
    make_up_discharge_down_water_lev_graph

#条件としての上流の流量の作図
function _base_upstream_discharge_graph(
    japanese::Bool,
    max_num_time
    )
    x_label = _get_x_label_time_sec(japanese)
    y_label = _get_y_label_upstream_discharge_graph(japanese)
    
    p = plot(
        legend=:none,
        xlabel=x_label,
        xlims=(0,max_num_time),
        xticks=[0, 4e6, 8e6, 12e6],
        ylabel=y_label,
        ylims=(0,10000)
    )

    return p
end

function _base_downstream_water_level_graph(japanese, max_num_time)
    x_label = _get_x_label_time_sec(japanese)
    y_label = _get_y_label_downstream_water_level(japanese)
    
    p = plot(
        legend=:none,
        xlabel=x_label,
        xlims=(0,max_num_time),
        xticks=[0, 4e6, 8e6, 12e6],
        ylabel=y_label,
        ylims=(-1, 2)
    )

    return p
end

function _get_x_label_time_sec(japanese::Bool)

    if japanese==true
        x_label="秒数 (s)"
    else
        x_label="Seconds"
    end
    
    return x_label
end

function _get_y_label_upstream_discharge_graph(japanese)

    if japanese==true
        y_label="流量 (m³/s)"
    else
        y_label="Discharge (m³/s)"
    end
    
    return y_label
end

function _get_y_label_downstream_water_level(japanese)

    if japanese==true
        y_label="水位 (m)"
    else
        y_label="Water Level (m)"
    end
    
    return y_label
end

function _plot_target_array_graph!(
    p,
    time_data,
    target_array,
    color::Symbol,
    target_hours
    )

    plot!(
        p,
        time_data,
        target_array,
        linestyle=:dot,
        linecolor=:black
    )
    
    plot!(
        p,
        time_data[1:(target_hours+1)],
        target_array[1:(target_hours+1)],
        linecolor=color
    )

    return p
end

function make_upstream_discharge_graph(
    data_file,
    time_schedule,
    target_hours::Int;
    japanese::Bool=false
    )

    time_data = unique(data_file[:, :T])
    max_num_time = maximum(time_data)

    discharge_data = time_schedule[:, :discharge_m3_s]
    
    p = _base_upstream_discharge_graph(japanese, max_num_time)
    
    _plot_target_array_graph!(
        p,
        time_data,
        discharge_data,
        :red,
        target_hours
    )
    
    return p

end

function make_upstream_discharge_graph(
    data_file,
    time_schedule,
    each_year_timing,
    target_hours;
    japanese::Bool=false    
    )

    time_data = unique(data_file[:, :T])
    max_num_time = maximum(time_data)

    discharge_data = time_schedule[:, :discharge_m3_s]

    p = _base_upstream_discharge_graph(japanese, max_num_time)

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    _plot_target_array_graph!(
        p,
        time_data,
        discharge_data,
        :red,
        target_hours
    )
    
    return p

end

#条件としての河口の水位の作図

function make_downstream_water_level_graph(
    data_file,
    time_schedule,
    target_hours::Int;
    japanese::Bool=false    
    )

    time_data = unique(data_file[:, :T])
    max_num_time = maximum(time_data)
    
    water_level_data = time_schedule[:, :water_level_m]

    p = _base_downstream_water_level_graph(japanese, max_num_time)

    _plot_target_array_graph!(
        p,
        time_data,
        water_level_data,
        :midnightblue,
        target_hours
    )
    
    return p

end

function make_downstream_water_level_graph(
    data_file,
    time_schedule,
    each_year_timing,
    target_hours::Int;
    japanese::Bool=false    
    )

    time_data = unique(data_file[:, :T])
    max_num_time = maximum(time_data)
    
    water_level_data = time_schedule[:, :water_level_m]

    p = _base_downstream_water_level_graph(japanese, max_num_time)

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    _plot_target_array_graph!(
        p,
        time_data,
        water_level_data,
        :midnightblue,
        target_hours
    )
    
    return p

end

# 2つ並べた図を作りたい
function make_up_discharge_down_water_lev_graph(
    data_file,
    time_schedule,
    target_hours;
    japanese::Bool=false
    )

    p1 = make_upstream_discharge_graph(
        data_file,
        time_schedule,
        target_hours,
        japanese=japanese
    )

    plot!(p1, xticks=0, xlabel="", title="(a)")

    p2 = make_downstream_water_level_graph(
        data_file,
        time_schedule,
        target_hours,
        japanese=japanese
    )

    plot!(p2, title="(b)")

    p = plot(p1, p2,
             titlelocation=:left,
             layout=Plots.@layout[a;b],
             top_margin=8Plots.mm)
    
    return p
end   

function make_up_discharge_down_water_lev_graph(
    data_file,
    time_schedule,
    each_year_timing,
    target_hours;
    japanese::Bool=false
    )

    p1 = make_upstream_discharge_graph(
        data_file,
        time_schedule,
        each_year_timing,
        target_hours,
        japanese=japanese
    )

    plot!(p1, xticks=0, xlabel="", title="(a)")

    p2 = make_downstream_water_level_graph(
        data_file,
        time_schedule,
        each_year_timing,
        target_hours,
        japanese=japanese
    )

    plot!(p2, title="(b)")

    p = plot(p1, p2,
             titlelocation=:left,
             layout=Plots.@layout[a;b],
             top_margin=8Plots.mm)
    
    return p
end   

end
