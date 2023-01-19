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

export graph_ratio_simulated_particle_size_dist,
    graph_average_simulated_particle_size_dist,
    graph_average_simulated_particle_size_fluc
    

#河床の粒度分布を計算する関数
function simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    hours_now::Int
    )

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

function get_average_simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    hours_now::Int
    )

    start_index, finish_index = decide_index_number(hours_now)

    num_particle_size        = size(sediment_size[:, :Np], 1)
    string_num_particle_size = @sprintf("%02i", num_particle_size)

    simulated_particle_dist = Matrix(
                                       data_file[start_index:finish_index,
                                       Between("fmc01", string("fmc", string_num_particle_size))]
                                   )

    average_simulated_particle_size_dist =
        get_average_simulated_particle_size_dist(
            simulated_particle_dist,
            sediment_size
        )

    return average_simulated_particle_size_dist
end

function get_average_simulated_particle_size_dist(
    simulated_particle_size_dist::Matrix{T},
    sediment_size::DataFrame
    ) where {T}

    average_simulated_particle_size_dist =
        zeros(
            T,
            size(simulated_particle_size_dist, 1)
        )

    get_average_simulated_particle_size_dist!(
        average_simulated_particle_size_dist,
        simulated_particle_size_dist,
        sediment_size[!, 3]
    )
    
    return average_simulated_particle_size_dist
end

function get_average_simulated_particle_size_dist!(
    average_simulated_particle_size_dist::Vector{T},
    simulated_particle_size_dist::Matrix{T},    
    sediment_size_vec::Vector{T}
    ) where {T}
    
    average_simulated_particle_size_dist .=
        simulated_particle_size_dist * sediment_size_vec
    
end

# 縦軸に割合(%)，横軸に河口からの距離(km)とした，
# グラフを作る．
function graph_ratio_simulated_particle_size_dist(
    data_file::DataFrame,
    sediment_size::DataFrame,
    time_schedule::DataFrame,
    hours_now::Int;
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
        l_title="粒径 (mm)"
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

function graph_average_simulated_particle_size_dist(
    sediment_size::DataFrame,
    time_schedule::DataFrame,
    hours_now::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    p = _graph_average_simulated_particle_size_dist(
            time_schedule,
            hours_now,
            japanese=japanese
        ) 
    
    distance_from_estuary = 0:0.2:77.8
    
    for i in 1:N

        average_simulated_particle_size_dist =
            get_average_simulated_particle_size_dist(
                df_vararg[i],
                sediment_size,
                hours_now
            )

        legend_label = string("Case ", i)
            
        plot!(
            p, distance_from_estuary,
            reverse(average_simulated_particle_size_dist),
            label=legend_label
        )

    end

    average_simulated_particle_size_dist =
        get_average_simulated_particle_size_dist(
            df_vararg[1],
            sediment_size,
            0
        )
    
    legend_label = "Initial Condition"
    if japanese==true
        legend_label="初期条件"
    end        
            
    plot!(
        p, distance_from_estuary,
        reverse(average_simulated_particle_size_dist),
        label=legend_label,
        linecolor=:midnightblue
    )    

    return p
end

function graph_average_simulated_particle_size_dist(
    time_schedule::DataFrame,
    hours_now::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    p = _graph_average_simulated_particle_size_dist(
            time_schedule,
            hours_now,
            japanese=japanese
        ) 

    distance_from_estuary = 0:0.2:77.8

    start_index, finish_index = decide_index_number(hours_now)
    
    for i in 1:N

        simu_particle_size_dist = df_vararg[i][start_index:finish_index, :Dmave] * 1000
    
        legend_label = string("Case ", i)
            
        plot!(
            p, distance_from_estuary,
            reverse(simu_particle_size_dist),
            label=legend_label
        )

    end

    start_index, finish_index = decide_index_number(0)
    
    simu_particle_size_dist = df_vararg[1][start_index:finish_index, :Dmave] * 1000
    
    legend_label = "Initial Condition"
    if japanese==true
        legend_label="初期条件"
    end        
    
    plot!(
        p, distance_from_estuary,
        reverse(simu_particle_size_dist),
        label=legend_label,
        linecolor=:midnightblue
    )    

    return p
end

function _graph_average_simulated_particle_size_dist(
    time_schedule::DataFrame,
    hours_now::Int;
    japanese::Bool=false
    )

    want_title = making_time_series_title("",
        hours_now, time_schedule)

    x_label="Distance from the estuary (km)"
    y_label="Mean Diameter (mm)"

    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="平均粒径 (mm)"
    end        
    p = vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(
        p,
        title=want_title,
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        xlims=(0,77.8),
        ylims=(0, 200),
        legend=:topleft
    )

    return p
end

function _graph_average_simulated_particle_size_fluc!(
    p::Plots.Plot,
    keys_year,
    sediment_size,
    each_year_timing,
    df_vararg::NTuple{N, DataFrame}
    ) where {N}

    
    for i in 1:N
        
        fluc_average_value = zeros(length(keys_year)+1)

        for (index, year) in enumerate(keys_year)
            average_simulated_particle_size_dist =
                get_average_simulated_particle_size_dist(
                    df_vararg[i],
                    sediment_size,
                    each_year_timing[year][1]
                )

            fluc_average_value[index] =
                mean(average_simulated_particle_size_dist)
        end

        average_simulated_particle_size_dist =
            get_average_simulated_particle_size_dist(
                df_vararg[i],
                sediment_size,
                each_year_timing[keys_year[end]][2]
            )

        fluc_average_value[end] =
            mean(average_simulated_particle_size_dist)

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

function _graph_average_simulated_particle_size_fluc!(
    p::Plots.Plot,
    keys_year,
    sediment_size,
    each_year_timing,
    i_begin::Int,
    i_end::Int,
    df_vararg::NTuple{N, DataFrame}
    ) where {N}

    for i in 1:N
        
        fluc_average_value = zeros(length(keys_year)+1)

        for (index, year) in enumerate(keys_year)
            average_simulated_particle_size_dist =
                get_average_simulated_particle_size_dist(
                    df_vararg[i],
                    sediment_size,
                    each_year_timing[year][1]
                )

            fluc_average_value[index] =
                mean(average_simulated_particle_size_dist[i_begin:i_end])
        end

        average_simulated_particle_size_dist =
            get_average_simulated_particle_size_dist(
                df_vararg[i],
                sediment_size,
                each_year_timing[keys_year[end]][2]
            )

        fluc_average_value[end] =
            mean(average_simulated_particle_size_dist[i_begin:i_end])

        i_max = length(average_simulated_particle_size_dist)

        title_s = @sprintf("%.1f km - %.1f km", 0.2*(i_max-i_end), 0.2*(i_max-i_begin))
        
        legend_label = string("Case ", i)
                    
        plot!(
            p,
            [keys_year; keys_year[end]+1],
            fluc_average_value,
            markershape=:auto,
            label=legend_label,
            title=title_s
        )
        
    end

    return p
end

function _graph_average_simulated_particle_size_fluc(
    keys_year,
    japanese::Bool
    )

    y_label="Mean Diameter (mm)"

    if japanese==true
        y_label="平均粒径 (mm)"
    end        

    p = vline([0], line=:black, label="", linestyle=:dot, linewidth=1)
    plot!(
        p,
        ylabel=y_label,
        xlims=(keys_year[begin], keys_year[end]+1),
        legend=:bottomleft
    )

    return p
end

function graph_average_simulated_particle_size_fluc(
    sediment_size,
    each_year_timing,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing)))
    
    p = _graph_average_simulated_particle_size_fluc(
        keys_year,
        japanese
    )
    
    _graph_average_simulated_particle_size_fluc!(
        p,
        keys_year,
        sediment_size,
        each_year_timing,
        df_vararg
    )

    return p
end

function graph_average_simulated_particle_size_fluc(
    sediment_size,
    each_year_timing,
    i_begin::Int,
    i_end::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    keys_year = sort(collect(keys(each_year_timing)))
    
    p = _graph_average_simulated_particle_size_fluc(
        keys_year,
        japanese
    )

    _graph_average_simulated_particle_size_fluc!(
        p,
        keys_year,
        sediment_size,
        each_year_timing,
        i_begin,
        i_end,
        df_vararg
    )

    return p
end

end
