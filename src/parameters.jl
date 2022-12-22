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

using Printf,
      Plots,
      Statistics,
      DataFrames,
      StatsPlots,
      CSV,
    ..GeneralGraphModule

export average_neighbors_target_hour,
    calc_energy_slope,
    make_figure_energy_slope,
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

    start_i, final_i = decide_index_number(target_hour)

    normal_array = df[start_i:final_i, target_symbol]
    
    return_array = zeros(Float64, length(normal_array)-1)
    
    average_neighbors_target_hour!(return_array, normal_array)

    return return_array

end

function calc_energy_slope(df, param::Param, target_hour::Int)

    Aw = average_neighbors_target_hour(df, :Aw, target_hour)
    Bw = average_neighbors_target_hour(df, :Bw, target_hour)

    Qw = average_neighbors_target_hour(df, :Qw, target_hour)

    i_e = (param.manning_n .* Qw ./ (Aw ./ Bw) .^ (2/3) ./ Aw) .^2

    return i_e
end

function make_figure_energy_slope(df, time_schedule, param::Param, target_hour::Int)

    i_e = calc_energy_slope(df, param, target_hour)
    X   = average_neighbors_target_hour(df, :I, target_hour) ./ 1000

    want_title = making_time_series_title("", target_hour, target_hour * 3600, time_schedule)
    
    Plots.vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    Plots.plot!(X, reverse(i_e), xlims=(0, 77.8), xlabel="河口からの距離 (km)",
                ylabel="エネルギー勾配 (-)", ylims=(0,0.5),
                legend=:none, title=want_title)

end

end
