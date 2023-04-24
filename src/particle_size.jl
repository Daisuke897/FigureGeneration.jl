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

export
    graph_ratio_simulated_particle_size_dist,
    graph_average_simulated_particle_size_dist,
    graph_average_simulated_particle_size_fluc,
    graph_cumulative_change_in_mean_diameter,
    graph_cumulative_ratio_in_mean_diameter,
    graph_cumulative_rate_in_mean_diameter,
    graph_cumulative_rate_variation_in_mean_diameter,
    graph_condition_change_in_mean_diameter,
    graph_condition_ratio_in_mean_diameter,
    graph_cumulative_condition_change_in_mean_diameter,
    graph_cumulative_condition_rate_in_mean_diameter,
    graph_measured_distribution

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

    vline!([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    hline!([50], line=:black, label="", linestyle=:dash, linewidth=2)

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

    legend_label = "Initial Condition"
    if japanese==true
        legend_label="初期条件"
    end

    average_simulated_particle_size_dist =
        get_average_simulated_particle_size_dist(
            df_vararg[1],
            sediment_size,
            0
        )

    plot!(
        p, distance_from_estuary,
        reverse(average_simulated_particle_size_dist),
        label=legend_label,
        linecolor=:midnightblue
    )    
    
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

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    
    
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

    legend_label = "Initial Condition"
    if japanese==true
        legend_label="初期条件"
    end
    
    start_index, finish_index = decide_index_number(0)
    
    simu_particle_size_dist = df_vararg[1][start_index:finish_index, :Dmave] * 1000
    
    plot!(
        p, distance_from_estuary,
        reverse(simu_particle_size_dist),
        label=legend_label,
        linecolor=:midnightblue
    )
    
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

    
    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    

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

    p = plot(
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

function graph_cumulative_change_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    x_label = "Distance from the estuary (km)"
    y_label="Cumulative variation (mm)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="累積変化量 (mm)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
    end

    p=plot(
        legend=:bottomleft,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-150, 100),
        ylabel=y_label,
        title=title_s
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    for i in 1:N

        cum_change_simu_particle_size =
            _average_simulated_particle_size_diff(
                df_vararg[i],
                sediment_size,
                start_target_hour,
                final_target_hour
            )

        legend_label = string("Case ", i)

        X = [0.2*(i-1) for i in 1:length(cum_change_simu_particle_size)]
        
        plot!(
            p,
            X,
            reverse(cum_change_simu_particle_size),
            label=legend_label
        )

    end

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)        

    return p
    
end

function graph_cumulative_condition_change_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vector;
    japanese::Bool=false
    )
    
    l = @layout[a; b]
    
    p1 = graph_cumulative_change_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[], ylims=(-150, 100))
    
    p2 = graph_condition_change_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p2, title="", legend=:bottomright, ylims=(-20, 20))
    
    p = plot(
        p1,
        p2,
        layout=l,
        tickfontsize=11,
        guidefontsize=11,
        legend_font_pointsize=7
    )
    
    return p
    
end

function graph_cumulative_ratio_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    x_label = "Distance from the estuary (km)"
    y_label="Ratio (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="比率 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
    end

    p=plot(
        legend=:topleft,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    

    for i in 1:N

        ratio_simu_particle_size =
            _average_simulated_particle_size_ratio(
                df_vararg[i],
                sediment_size,
                start_target_hour,
                final_target_hour
            )

        legend_label = string("Case ", i)

        X = [0.2*(i-1) for i in 1:length(ratio_simu_particle_size)]
        
        plot!(
            p,
            X,
            reverse(ratio_simu_particle_size),
            label=legend_label
        )

    end

    return p
    
end

function graph_cumulative_rate_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    x_label = "Distance from the estuary (km)"
    y_label="Rate (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化率 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
    end

    p=plot(
        legend=:top,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s,
        ylims=(-2,40)
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    for i in 1:N

        rate_simu_particle_size =
            _average_simulated_particle_size_ratio(
                df_vararg[i],
                sediment_size,
                start_target_hour,
                final_target_hour
            ) .- 1

        legend_label = string("Case ", i)

        X = [0.2*(i-1) for i in 1:length(rate_simu_particle_size)]
        
        plot!(
            p,
            X,
            reverse(rate_simu_particle_size),
            label=legend_label
        )

    end

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)    

    return p
    
end

function graph_cumulative_rate_variation_in_mean_diameter(
    sediment_size,
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
    y_label="Variation (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化量 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:bottom,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s,
        ylims=(-2,2)
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    base_mean_particle =
        _average_simulated_particle_size_ratio(
            df_base,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1

    with_mining_mean_particle =
        _average_simulated_particle_size_ratio(
            df_with_mining,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1
        
    with_dam_mean_particle =
        _average_simulated_particle_size_ratio(
            df_with_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1

    with_mining_and_dam_mean_particle =
        _average_simulated_particle_size_ratio(
            df_with_mining_and_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
            ) .- 1
    
    change_by_mining         = with_mining_mean_particle -
        base_mean_particle
    change_by_dam            = with_dam_mean_particle -
        base_mean_particle
    change_by_mining_and_dam = with_mining_and_dam_mean_particle -
        base_mean_particle

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

function graph_cumulative_condition_rate_in_mean_diameter(
    sediment_size,
    start_year::Int,
    final_year::Int,
    start_target_hour::Int,
    final_target_hour::Int,
    df_vector;
    japanese::Bool=false
    )
    
    l = @layout[a; b]
    
    p1 = graph_cumulative_rate_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p1, xlabel="", xticks=[])
    
    p2 = graph_cumulative_rate_variation_in_mean_diameter(
        sediment_size,
        start_year,
        final_year,
        start_target_hour,
        final_target_hour,
        df_vector...;
        japanese=japanese
    )
    
    plot!(p2, title="")
    
    p = plot(
        p1,
        p2,
        layout=l,
        tickfontsize=11,
        guidefontsize=11,
        legend_font_pointsize=8
    )
    
    return p
    
end

function graph_condition_change_in_mean_diameter(
    sediment_size,
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
    y_label = "Variation (mm)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="変化量 (mm)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:bottomright,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylims=(-15, 15),
        ylabel=y_label,
        title=title_s
    )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)

    base_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_base,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_and_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining_and_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )
    
    change_by_mining         = with_mining_mean_particle_diff -
        base_mean_particle_diff
    change_by_dam            = with_dam_mean_particle_diff    -
        base_mean_particle_diff
    change_by_mining_and_dam = with_mining_and_dam_mean_particle_diff -
        base_mean_particle_diff
    
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

function graph_condition_ratio_in_mean_diameter(
    sediment_size,
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
    y_label = "Ratio (-)"
    title_s = string("Mean Diameter  ", start_year, "-", final_year)
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    
    if japanese==true
        x_label="河口からの距離 (km)"
        y_label="比率 (-)"
        title_s = string("平均粒径 ", start_year, "-", final_year)
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end

    p=plot(
        legend=:bottomright,
        xlims=(0, 77.8),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=x_label,
        ylabel=y_label,
        title=title_s
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    
    base_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_base,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )

    with_mining_and_dam_mean_particle_diff =
        _average_simulated_particle_size_diff(
            df_with_mining_and_dam,
            sediment_size,
            start_target_hour,
            final_target_hour
        )
    
    change_by_mining         = with_mining_mean_particle_diff ./
        base_mean_particle_diff
    change_by_dam            = with_dam_mean_particle_diff    ./
        base_mean_particle_diff
    change_by_mining_and_dam = with_mining_and_dam_mean_particle_diff ./
        base_mean_particle_diff
    
    X = [0.2*(i-1) for i in 1:length(base_mean_particle_diff)]
        
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

    return p

end

function _average_simulated_particle_size_diff(
    df::DataFrame,
    sediment_size::DataFrame,
    start_target_hour::Int,
    final_target_hour::Int
    )

    mean_particle_start =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            start_target_hour
        )

    mean_particle_final =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            final_target_hour
        )
    
    mean_particle_diff =
        mean_particle_final - mean_particle_start

    return mean_particle_diff

end

function _average_simulated_particle_size_ratio(
    df::DataFrame,
    sediment_size::DataFrame,
    start_target_hour::Int,
    final_target_hour::Int
    )

    mean_particle_start =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            start_target_hour
        )

    mean_particle_final =
        get_average_simulated_particle_size_dist(
            df,
            sediment_size,
            final_target_hour
        )
    
    mean_particle_ratio =
        mean_particle_final ./ mean_particle_start

    return mean_particle_ratio

end

function graph_measured_distribution(
        fmini::DataFrame,
        sediment_size::DataFrame,
        distance_km::Vector{Int},
        max_area_index::Int;
        japanese::Bool=false
    )
    
    if japanese == true 
        x_label  = "粒径 (mm)" 
        y_label  = "累積 (%)"
        t_legend = "河口からの\n距離 (km)"
    else
        x_label  = "Particle size (mm)"
        y_label  = "Cumulative volume (%)"
        t_legend = "Distance from\nthe estuary\n(km)"
    end
    
    p = plot(
        legend=:outerright,
        ylims=(0, 100),
        ylabel=y_label,
        xlims=(0.01, 1000),
        xlabel=x_label,
        xscale=:log10,
        label_title=t_legend
    )
    
    num_class_size = size(sediment_size, 1)
    
    for km in distance_km
    
        area_index = max_area_index - 5 * km
        
        cum_vol = cumsum(
            [i for i in fmini[area_index, 2:(1+num_class_size)]]
        ) * 100
        
        plot!(
            p,
            sediment_size[!, 3],
            cum_vol,
            label=km,
            markershape=:auto,
            markersize=5
        )
        
    end
    
    return p
    
end

end
