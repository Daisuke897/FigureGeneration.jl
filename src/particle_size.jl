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

export graph_ratio_simulated_particle_size_dist

#河床の粒度分布を計算する関数
function simulated_particle_size_dist(data_file::DataFrame,
    sediment_size::DataFrame, hours_now::Integer)

    start_index, finish_index = decide_index_number(hours_now)

    num_particle_size        = size(sediment_size[:, :Np], 1)
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

# 縦軸に割合(%)，横軸に河口からの距離(km)とした，
# グラフを作る．
function graph_ratio_simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    time_schedule::DataFrame,
    hours_now::Integer;
    japanese::Bool=false
    )

    start_index, finish_index = decide_index_number(hours_now)

    num_particle_size        = size(sediment_size[:, :Np], 1)
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
        l_title="粒経 (mm)"
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

    vline!([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    hline!([50], line=:black, label="", linestyle=:dash, linewidth=3)

    return p
end

end
