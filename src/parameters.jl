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

module Parameters

import Plots,
       DataFrames,
       ..GeneralGraphModule

export make_figure_energy_slope,
       make_figure_friction_velocity,
       params

struct Param{T<:AbstractFloat}
    manning_n::T
    g::T
end

params = Param{Float64}(0.30, 9.81)

function average_neighbors_target_hour!(return_array, normal_array)

    return_array .= ((normal_array .+ circshift(normal_array, -1)) ./ 2)[1:end-1]

    return return_array

end

function average_neighbors_target_hour(df, target_symbol::Symbol, target_hour::Int)

    start_i, final_i = GeneralGraphModule.decide_index_number(target_hour)

    normal_array = @view df[start_i:final_i, target_symbol]
    
    return_array = @view ((normal_array .+ circshift(normal_array, -1)) ./ 2)[1:end-1]
    
    return return_array

end

function calc_hydraulic_depth(area, width, target_hour::Int)

    hydraulic_depth = area / width

    return hydraulic_depth
end

function calc_energy_slope(area, width, discharge, manning_n, target_hour::Int)

    h_d = calc_hydraulic_depth(area, width, target_hour)

    i_e = (manning_n * discharge / (h_d ^ (2/3)) / area) ^2

    return i_e
end

function calc_energy_slope(df, param::Param, target_hour::Int)

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    i_e = calc_energy_slope.(area, width, discharge, param.manning_n, target_hour::Int)

    return i_e
end

function calc_friction_velocity(
    area,
    width,
    discharge,
    manning_n,
    gravity_accel,
    target_hour::Int
    )

    hydraulic_depth = calc_hydraulic_depth(
        area, width, target_hour
    )
    
    energy_slope = calc_energy_slope(
        area, width, discharge, manning_n, target_hour
    )
    
    u_star = sqrt(gravity_accel * hydraulic_depth * energy_slope)

    return u_star
end

function calc_friction_velocity(
    df,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    u_star    = calc_friction_velocity.(
        area,
        width,
        discharge,
        param.manning_n,
        param.g,
        target_hour
    )
    
    return u_star
end

function make_figure_energy_slope(
    df,
    time_schedule,
    param::Param,
    target_hour::Int;
    japanese::Bool=false
)

    i_e = calc_energy_slope(df, param, target_hour)
    X   = average_neighbors_target_hour(df, :I, target_hour) ./ 1000

    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Energy Slope (-)"

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="エネルギー勾配 (-)"
    end
    
    Plots.vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    Plots.plot!(X, reverse(i_e), xlims=(0, 77.8), xlabel=xlabel_title,
                ylabel=ylabel_title, ylims=(0,0.5),
                legend=:none, title=want_title)

end

function make_figure_friction_velocity(
    df,
    time_schedule,
    param::Param,
    target_hour::Int;
    japanese::Bool=false
)

    u_star = calc_friction_velocity(df, param, target_hour)
    X      = average_neighbors_target_hour(df, :I, target_hour) ./ 1000

    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Friction Velocity (m/s)"

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="摩擦速度 (m/s)"
    end
    
    Plots.vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    Plots.plot!(X, reverse(u_star), xlims=(0, 77.8), xlabel=xlabel_title,
                ylims=(0, 4.0), ylabel=ylabel_title,
                legend=:none, title=want_title)

end

end
