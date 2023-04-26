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
       ..GeneralGraphModule,
       ..ParticleSize

export make_figure_energy_slope,
    make_figure_friction_velocity,
    make_figure_non_dimensional_shear_stress,
    make_figure_area,    
    make_figure_width,    
    make_figure_velocity,
    make_figure_discharge,    
    make_graph_time_series_area_water,
    make_graph_time_series_width_water,
    make_graph_time_series_velocity_water,
    make_graph_time_series_discharge_water,        
    params

struct Param{T<:AbstractFloat}
    manning_n::T
    g::T
    specific_gravity::T
end

params = Param{Float64}(0.30, 9.81, 1.65)

function average_neighbors_target_hour!(
    return_array::AbstractVector{T},
    normal_array::AbstractVector{T}
    ) where {T<:AbstractFloat}

    return_array .= ((normal_array .+ circshift(normal_array, -1)) ./ 2)[1:end-1]

    return return_array
end

function average_neighbors_target_hour(normal_array::AbstractVector{T}) where {T<:AbstractFloat}

    return_array = zeros(T, length(normal_array)-1)

    average_neighbors_target_hour!(
        return_array,
        normal_array
    )    
    
    return return_array
end

function average_neighbors_target_hour(
    df::DataFrames.DataFrame,
    target_symbol::Symbol,
    target_hour::Int
    )

    start_i, final_i = GeneralGraphModule.decide_index_number(target_hour)

    normal_array = @view df[start_i:final_i, target_symbol]

    return_array = average_neighbors_target_hour(normal_array)
    
    return return_array
end

function calc_hydraulic_depth(area::T, width::T) where {T<:AbstractFloat}

    hydraulic_depth = area / width

    return hydraulic_depth
end

function calc_energy_slope(
    area::T,
    width::T,
    discharge::T,
    manning_n::T
    ) where {T<:AbstractFloat}

    h_d = calc_hydraulic_depth(area, width)

    i_e = (manning_n * discharge / (h_d ^ (2/3)) / area) ^2

    return i_e
end

function calc_energy_slope(df, param::Param, target_hour::Int)

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    i_e = calc_energy_slope.(area, width, discharge, param.manning_n)

    return i_e
end

function calc_friction_velocity(
    area::T,
    width::T,
    discharge::T,
    manning_n::T,
    gravity_accel::T
    ) where {T<:AbstractFloat}

    hydraulic_depth = calc_hydraulic_depth(
        area,
        width
    )
    
    energy_slope = calc_energy_slope(
        area, width, discharge, manning_n
    )
    
    uₛ = sqrt(gravity_accel * hydraulic_depth * energy_slope)

    return uₛ
end

function calc_friction_velocity(
    df::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    uₛ    = calc_friction_velocity.(
        area,
        width,
        discharge,
        param.manning_n,
        param.g
    )
    
    return uₛ
end

function calc_non_dimensional_shear_stress(
    uₛ::T,
    specific_gravity::T,
    gravity_accel::T,
    mean_diameter::T    
    ) where {T<:AbstractFloat}

    τₛ = (uₛ^2) / specific_gravity / gravity_accel / mean_diameter

    return τₛ
end

function calc_non_dimensional_shear_stress(
    area::T,
    width::T,
    discharge::T,
    manning_n::T,
    specific_gravity::T,
    gravity_accel::T,
    mean_diameter::T    
    ) where {T<:AbstractFloat}

    uₛ = calc_friction_velocity(
        area,
        width,
        discharge,
        manning_n,
        gravity_accel
       )


    τₛ = calc_non_dimensional_shear_stress(
        uₛ,
        specific_gravity,
        gravity_accel,
        mean_diameter    
    )

    return τₛ
end

function calc_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    mean_diameter_dist = ParticleSize.get_average_simulated_particle_size_dist(
        df,
        sediment_size,
        target_hour
    )
    mean_diameter = average_neighbors_target_hour(mean_diameter_dist)

    τₛ = calc_non_dimensional_shear_stress.(
        area,
        width,
        discharge,
        param.manning_n,
        param.specific_gravity,
        param.g,
        mean_diameter    
    )
    
    return τₛ
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
    Plots.plot!(X, reverse(u_star),
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, 4.0),
                ylabel=ylabel_title,
                legend=:none,
                title=want_title)
end

function make_figure_non_dimensional_shear_stress(
    df,
    sediment_size,
    time_schedule,
    param::Param,
    target_hour::Int;
    japanese::Bool=false
)

    τₛ = calc_non_dimensional_shear_stress(df, sediment_size, param, target_hour)
    X  = average_neighbors_target_hour(df, :I, target_hour) ./ 1000

    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Non Dimensional\nShear Stress (-)"

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="無次元掃流力 (-)"
    end
    
    Plots.vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    Plots.plot!(X, reverse(τₛ),
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, 1),
                ylabel=ylabel_title,
                legend=:none, title=want_title)

end

function make_figure_area(
    time_schedule,
    target_hour::Int,
    df::DataFrames.DataFrame;
    japanese::Bool=false
) 

    start_index, finish_index = GeneralGraphModule.decide_index_number(target_hour)

    len_num = finish_index - start_index + 1
    
    X = [0.2*(i-1) for i in 1:len_num]
    
    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Area (m²)"
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="面積 (m²)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, 7000),
                ylabel=ylabel_title,
                legend=:none, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)


    area = df[start_index:finish_index, :Aw]

    Plots.plot!(
        p,
        X,
        reverse(area),
        linecolor=:tomato
    )
        

    return p

end

function make_figure_width(
    time_schedule,
    target_hour::Int,
    df::DataFrames.DataFrame;
    japanese::Bool=false
) 

    start_index, finish_index = GeneralGraphModule.decide_index_number(target_hour)

    len_num = finish_index - start_index + 1
    
    X = [0.2*(i-1) for i in 1:len_num]
    
    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Width (m)"
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="川幅 (m)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, 2500),
                ylabel=ylabel_title,
                legend=:none, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)


    width = df[start_index:finish_index, :Bw]

    Plots.plot!(
        p,
        X,
        reverse(width),
        linecolor=:lightcoral
    )
        

    return p

end

function make_figure_velocity(
    time_schedule,
    target_hour::Int,
    df::DataFrames.DataFrame;
    japanese::Bool=false
) 

    start_index, finish_index = GeneralGraphModule.decide_index_number(target_hour)

    len_num = finish_index - start_index + 1
    
    X = [0.2*(i-1) for i in 1:len_num]
    
    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Velocity (m/s)"
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="流速 (m/s)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, 6),
                ylabel=ylabel_title,
                legend=:none, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)


    velocity = df[start_index:finish_index, :Ux]

    Plots.plot!(
        p,
        X,
        reverse(velocity),
        linecolor=:orangered
    )
        

    return p

end

function make_figure_velocity(
    time_schedule,
    target_hour::Int,
    df_vararg::Vararg{DataFrames.DataFrame, N};
    japanese::Bool=false
) where {N}

    start_index, finish_index = GeneralGraphModule.decide_index_number(target_hour)

    len_num = finish_index - start_index + 1
    
    X = [0.2*(i-1) for i in 1:len_num]
    
    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Velocity (m/s)"

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="流速 (m/s)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, 4),
                ylabel=ylabel_title,
                legend=:topleft, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    for i in 1:N

        velocity = df_vararg[i][start_index:finish_index, :Ux]

        Plots.plot!(
            p,
            X,
            reverse(velocity),
            label=string("Case ", i)
        )
        
    end

    return p

end

function make_figure_discharge(
    time_schedule,
    target_hour::Int,
    df::DataFrames.DataFrame;
    japanese::Bool=false
) 

    start_index, finish_index = GeneralGraphModule.decide_index_number(target_hour)

    len_num = finish_index - start_index + 1
    
    X = [0.2*(i-1) for i in 1:len_num]
    
    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Discharge (m³/s)"
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="流量 (m³/s)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(0, Inf),
                ylabel=ylabel_title,
                legend=:none, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)


    discharge = df[start_index:finish_index, :Qw]

    Plots.plot!(
        p,
        X,
        reverse(discharge),
        linecolor=:red
    )
        

    return p

end

function make_graph_time_series_area_water(
    area_index::Int,
    target_hours::Int,
    river_length_km::Float64,
    each_year_timing,
    df::DataFrames.DataFrame;
    japanese::Bool=false
)
    
    area_km = abs(river_length_km - 0.2 * (area_index - 1))    
    
    if japanese == true

        x_label="時間 (s)"
        y_label="面積 (m²)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")

    elseif japanese == false

        x_label="Time (s)"
        y_label="Area (m²)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")

    end

    time_data = unique(df[:, :T])
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    p = Plots.plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
#        ylims=(0, 140),
        ylabel=y_label,
        title=t_title,
        legend=:none,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
#        palette=:tab20,
#        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    area_time_series = zeros(Float64, num_time)

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        area_time_series[j] = df[i_first:i_final, :Aw][area_index]

    end

    Plots.plot!(
        p,
        time_data,
        area_time_series,
        linewidth=1,
        linestyle=:dot
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        area_time_series[1:target_hours],
        linecolor=:tomato
    )

    return p

end

function make_graph_time_series_width_water(
    area_index::Int,
    target_hours::Int,
    river_length_km::Float64,
    each_year_timing,
    df::DataFrames.DataFrame;
    japanese::Bool=false
)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    
    
    if japanese == true

        x_label="時間 (s)"
        y_label="幅 (m)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")

    elseif japanese == false

        x_label="Time (s)"
        y_label="Width (m)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")

    end

    time_data = unique(df[:, :T])
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    p = Plots.plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
#        ylims=(0, 140),
        ylabel=y_label,
        title=t_title,
        legend=:none,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
#        palette=:tab20,
#        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    width_time_series = zeros(Float64, num_time)

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        width_time_series[j] = df[i_first:i_final, :Bw][area_index]

    end

    Plots.plot!(
        p,
        time_data,
        width_time_series,
        linewidth=1,
        linestyle=:dot
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        width_time_series[1:target_hours],
        linecolor=:lightcoral
    )

    return p

end

function make_graph_time_series_velocity_water(
    area_index::Int,
    target_hours::Int,
    river_length_km::Float64,
    each_year_timing,
    df::DataFrames.DataFrame;
    japanese::Bool=false
)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    
    
    if japanese == true

        x_label="時間 (s)"
        y_label="流速 (m/s)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")

    elseif japanese == false

        x_label="Time (s)"
        y_label="Velocity (m/s)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")

    end

    time_data = unique(df[:, :T])
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    p = Plots.plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
#        ylims=(0, 140),
        ylabel=y_label,
        title=t_title,
        legend=:none,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
#        palette=:tab20,
#        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    velocity_time_series = zeros(Float64, num_time)

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        velocity_time_series[j] = df[i_first:i_final, :Ux][area_index]

    end

    Plots.plot!(
        p,
        time_data,
        velocity_time_series,
        linewidth=1,
        linestyle=:dot
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        velocity_time_series[1:target_hours],
        linecolor=:orangered
    )

    return p

end

function make_graph_time_series_discharge_water(
    area_index::Int,
    target_hours::Int,
    river_length_km::Float64,
    each_year_timing,
    df::DataFrames.DataFrame;
    japanese::Bool=false
)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    
    
    if japanese == true

        x_label="時間 (s)"
        y_label="流量 (m³/s)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")

    elseif japanese == false

        x_label="Time (s)"
        y_label="Discharge (m³/s)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")

    end

    time_data = unique(df[:, :T])
    max_num_time = maximum(time_data)
    num_time = length(time_data)

    p = Plots.plot(
        xlims=(0, max_num_time),
        xlabel=x_label,
#        ylims=(0, 140),
        ylabel=y_label,
        title=t_title,
        legend=:none,
        tickfontsize=10,
        guidefontsize=10,
        legend_font_pointsize=8,
        legend_title_font_pointsize=8,
#        palette=:tab20,
#        legend_title=t_legend
    )

    GeneralGraphModule._vline_per_year_timing!(
        p,
        each_year_timing
    )

    discharge_time_series = zeros(Float64, num_time)

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        discharge_time_series[j] = df[i_first:i_final, :Qw][area_index]

    end

    Plots.plot!(
        p,
        time_data,
        discharge_time_series,
        linewidth=1,
        linestyle=:dot
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        discharge_time_series[1:target_hours],
        linecolor=:red
    )

    return p

end

end
