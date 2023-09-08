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

import
    Plots,
    DataFrames,
    Statistics,
    ..GeneralGraphModule,
    ..ParticleSize,
    ..Main_df,
    ..distance_line,
    ..Each_year_timing

export
    make_graph_energy_slope,
    make_graph_friction_velocity,
    make_graph_area,
    make_graph_width,
    make_graph_velocity,
    make_graph_discharge,
    make_graph_water_level,
    make_graph_condition_change_water_level,    
    make_graph_time_series_area,
    make_graph_time_series_width,
    make_graph_time_series_velocity,
    make_graph_time_series_discharge,
    make_graph_time_series_water_level,
    make_graph_time_series_water_level_with_measured,
    params

struct Param{T<:AbstractFloat}
    manning_n::T
    g::T
    specific_gravity::T
    kinematic_viscosity::T
end

params = Param{Float64}(0.03, 9.81, 1.65, 1.004e-6)

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

function calc_energy_slope(
    df::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    i_e = calc_energy_slope.(area, width, discharge, param.manning_n)

    return i_e
end

include("sub_parameter/friction_velocity.jl")
include("sub_parameter/friction_velocity_plot.jl")

include("sub_parameter/shear_stress.jl")
include("sub_parameter/shear_stress_plot.jl")



"""

    calc_settling_velocity_by_rubey(param::Param{T}, diameter_m::T) where {T<:AbstractFloat}

Rubey式による沈降速度を計算する関数
`diameter_m`は粒径であり、単位はメートルである。
"""
function calc_settling_velocity_by_rubey(
    param::Param{T},
    diameter_m::T
    ) where {T<:AbstractFloat}
    
    tmp = 36 * param.kinematic_viscosity^2 / (param.specific_gravity * param.g * diameter_m^3)
    
    w_f = (sqrt(2.0/3.0 + tmp) - sqrt(tmp)) * sqrt(param.specific_gravity * param.g * diameter_m)
    
    return w_f
    
end

"""
エネルギー勾配の縦断分布のグラフを作成する。
"""
function make_graph_energy_slope(
    df_main::Main_df,
    time_schedule,
    param::Param,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="エネルギー勾配 (-)"
    else
        xlabel_title="Distance from the estuary (km)"
        ylabel_title="Energy slope (-)"
    end

    p = Plots.plot(
        xlims=(0, 77.8),
        xlabel=xlabel_title,
        ylims=(0, 0.01),
        ylabel=ylabel_title,
        legend=:best,
        title=want_title,
        xflip=true,
        palette=:default,
        xtick=[0, 20, 40, 60, 77.8]
    )
    
    Plots.vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    for (j, (i, label_string)) in enumerate(target_df)
        iₑ = calc_energy_slope(df_main.tuple[i], param, target_hour)
        X   = average_neighbors_target_hour(df_main.tuple[i], :I, target_hour) ./ 1000

        Plots.plot!(
            p,
            X,
            reverse(iₑ),
            label=label_string,
            linecolor=Plots.palette(:default)[j]
        )
    end

    return p

end



"""
摩擦速度の縦断分布のグラフを作成する。
"""
function make_graph_friction_velocity(
    df_main::Main_df,
    time_schedule,
    param::Param,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="摩擦速度 (m/s)"
    else
        xlabel_title="Distance from the estuary (km)"
        ylabel_title="Friction Velocity (m/s)"
    end

    p = Plots.plot(
        xlims=(0, 77.8),
        xlabel=xlabel_title,
        ylims=(0, 1.0),
        ylabel=ylabel_title,
        legend=:best,
        title=want_title,
        xflip=true,
        palette=:default,
        xticks=[0, 20, 40, 60, 77.8]
    )
    
    Plots.vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    for (j, (i, label_string)) in enumerate(target_df)
        u_star = calc_friction_velocity(df_main.tuple[i], param, target_hour)
        X      = average_neighbors_target_hour(df_main.tuple[i], :I, target_hour) ./ 1000


        Plots.plot!(
            p,
            X,
            reverse(u_star),
            xlims=(0, 77.8),
            label=label_string,
            linecolor=Plots.palette(:default)[j]
        )
    end

    return p
    
end

"""
河道の流水の面積の縦断分布のグラフを作成する。
"""
function make_graph_area(
    df_main::Main_df,
    time_schedule,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
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

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="面積 (m²)"
    else
        xlabel_title="Distance from the estuary (km)"
        ylabel_title="Area (m²)"
    end
    
    p = Plots.plot(
        xlims=(0, 77.8),
        xlabel=xlabel_title,
        xticks=[0, 20, 40, 60, 77.8],
        ylims=(0, 7000),
        ylabel=ylabel_title,
        legend=:topleft,
        xflip=true,
        palette=:default,
        title=want_title
    )

    Plots.vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    for (j, (i, label_string)) in enumerate(target_df)
        area = @view df_main.tuple[i][start_index:finish_index, :Aw]

        Plots.plot!(
            p,
            X,
            reverse(area),
            label=label_string,
            linecolor=Plots.palette(:default)[j]
        )
    end

    return p

end

"""
河道の流水の川幅の縦断分布のグラフを作成する。
"""
function make_graph_width(
    df_main::Main_df,
    time_schedule,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
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

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="川幅 (m)"
    else
        xlabel_title="Distance from the estuary (km)"
        ylabel_title="Width (m)"
    end

    p = Plots.plot(
        xlims=(0, 77.8),
        xlabel=xlabel_title,
        xticks=[0, 20, 40, 60, 77.8],
        ylims=(0, 3000),
        ylabel=ylabel_title,
        legend=:topleft,
        xflip=true,
        palette=:default,
        title=want_title
    )

    Plots.vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    for (j, (i, label_string)) in enumerate(target_df)
        width = @view df_main.tuple[i][start_index:finish_index, :Bw]

        Plots.plot!(
            p,
            X,
            reverse(width),
            label=label_string,
            linecolor=Plots.palette(:default)[j]
        )
    end
    
    return p

end

"""
河道の径深の縦断分布のグラフを作成する。
"""
function make_graph_hydraulic_depth(
    df_main::Main_df,
    time_schedule,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
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

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="径深 (m)"
    else
        xlabel_title="Distance from the estuary (km)"
        ylabel_title="Hydraulic depth (m)"
    end

    p = Plots.plot(
        xlims=(0, 77.8),
        xlabel=xlabel_title,
        xticks=[0, 20, 40, 60, 77.8],
        ylims=(0, 12),
        ylabel=ylabel_title,
        legend=:topright,
        xflip=true,
        palette=:default,
        title=want_title
    )

    Plots.vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    for (j, (i, label_string)) in enumerate(target_df)
        depth = df_main.tuple[i][start_index:finish_index, :Aw] ./
            df_main.tuple[i][start_index:finish_index, :Bw]

        Plots.plot!(
            p,
            X,
            reverse(depth),
            label=label_string,
            linecolor=Plots.palette(:default)[j]
        )
    end
    
    return p

end

function make_graph_velocity(
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

function make_graph_velocity(
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

function make_graph_discharge(
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

function make_graph_water_level(
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
    ylabel_title="Water Level (m)"
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="水位 (m)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(-5, 80),
                ylabel=ylabel_title,
                legend=:none, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)


    water_level = df[start_index:finish_index, :Z]

    Plots.plot!(
        p,
        X,
        reverse(water_level),
        linecolor=:dodgerblue
    )
        

    return p

end

function make_graph_water_level(
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
        time_schedule
    ) * "Discharge " * string(df_vararg[1][start_index, :Qw]) * " m³/s"

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Water Level (T.P. m)"
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="水位 (T.P. m)"
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylims=(-5, 85),
                ylabel=ylabel_title,
                legend=:topleft, title=want_title)

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    for i in 1:N

        Plots.plot!(
            p,
            X,
            reverse(df_vararg[i][start_index:finish_index, :Z]),
            label=string("Case ", i)
        )

    end

    return p

end

function make_graph_condition_change_water_level(
    time_schedule,
    target_hour::Int,
    df_base::DataFrames.DataFrame,
    df_with_mining::DataFrames.DataFrame,
    df_with_dam::DataFrames.DataFrame,
    df_with_mining_and_dam::DataFrames.DataFrame;
    japanese::Bool=false
)

    start_index, finish_index = GeneralGraphModule.decide_index_number(target_hour)

    len_num = finish_index - start_index + 1
    
    X = [0.2*(i-1) for i in 1:len_num]
    
    want_title = GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        time_schedule
    ) * "Discharge " * string(df_base[start_index, :Qw]) * " m³/s"

    xlabel_title="Distance from the Estuary (km)"
    ylabel_title="Differences (m)"
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]
    

    if japanese==true
        xlabel_title="河口からの距離 (km)"
        ylabel_title="変化 (m)"
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]
    end
    
    p = Plots.plot(
                xlims=(0, 77.8),
                xlabel=xlabel_title,
                xticks=[0, 20, 40, 60, 77.8],
                ylabel=ylabel_title,
                ylims=(-1.6,1.6),
                legend=:topleft, title=want_title)

    Plots.hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=2)    

    Plots.plot!(
        p,
        X,
        reverse(
            df_with_mining[start_index:finish_index, :Z]-df_base[start_index:finish_index, :Z]
        ),
        label=label_s[1]
    )

    Plots.plot!(
        p,
        X,
        reverse(
            df_with_dam[start_index:finish_index, :Z]-df_base[start_index:finish_index, :Z]
        ),
        label=label_s[2]
    )

    Plots.plot!(
        p,
        X,
        reverse(
            df_with_mining_and_dam[start_index:finish_index, :Z]-df_base[start_index:finish_index, :Z]
        ),
        label=label_s[3]
    )

    Plots.vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    return p

end

function make_graph_time_series_area(
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
        linestyle=:dot,
        linecolor=:black
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        area_time_series[1:target_hours],
        linecolor=:tomato
    )

    return p

end

function make_graph_time_series_width(
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
        linestyle=:dot,
        linecolor=:black
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        width_time_series[1:target_hours],
        linecolor=:lightcoral
    )

    return p

end

function make_graph_time_series_velocity(
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
        linestyle=:dot,
        linecolor=:black
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        velocity_time_series[1:target_hours],
        linecolor=:orangered
    )

    return p

end

function make_graph_time_series_discharge(
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
        linestyle=:dot,
        linecolor=:black
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        discharge_time_series[1:target_hours],
        linecolor=:red
    )

    return p

end

function make_graph_time_series_water_level(
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
        y_label="水位 (m)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")

    elseif japanese == false

        x_label="Time (s)"
        y_label="Water Level (m)"
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

    water_level_time_series = zeros(Float64, num_time)

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        water_level_time_series[j] = df[i_first:i_final, :Z][area_index]

    end

    Plots.plot!(
        p,
        time_data,
        water_level_time_series,
        linewidth=1,
        linestyle=:dot,
        linecolor=:black
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        water_level_time_series[1:target_hours],
        linecolor=:dodgerblue
    )

    return p

end

function make_graph_time_series_water_level_with_measured(
    area_index::Int,
    target_hours::Int,
    river_length_km::Float64,
    each_year_timing,
    df::DataFrames.DataFrame,
    df_measured::DataFrames.DataFrame;
    japanese::Bool=false
)

    area_km = abs(river_length_km - 0.2 * (area_index - 1))    
    
    if japanese == true

        x_label="時間 (s)"
        y_label="水位 (m)"
        t_title=string("河口から ", round(area_km, digits=2), " km 上流")
        t_label_1="再現値"
        t_label_2="観測値"

    elseif japanese == false

        x_label="Time (s)"
        y_label="Water Level (m)"
        t_title=string(round(area_km, digits=2), " km upstream from the estuary")
        t_label_1="Simulated"
        t_label_2="Measured"

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
        legend=:bottomleft,
        tickfontsize=12,
        guidefontsize=12,
        legend_font_pointsize=11,
        legend_title_font_pointsize=11,
#        palette=:tab20,
#        legend_title=t_legend
    )

    # GeneralGraphModule._vline_per_year_timing!(
    #     p,
    #     each_year_timing
    # )

    Plots.vline!(
        [each_year_timing[1975][1],
         each_year_timing[1985][1],
         each_year_timing[1995][1]] .* 3600,
        label="",
        linewidth=1,
        linestyle=:dash,
        linecolor=:black
    )
    
    water_level_time_series = zeros(Float64, num_time)

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        water_level_time_series[j] = df[i_first:i_final, :Z][area_index]

    end

    Plots.plot!(
        p,
        time_data,
        water_level_time_series,
        linewidth=1,
        linestyle=:dot,
        linecolor=:black,
        label=""
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],
        water_level_time_series[1:target_hours],
        linecolor=:dodgerblue,
        label=t_label_1
    )

    Plots.plot!(
        p,
        time_data[1:target_hours],        
        df_measured[!, :water_level],
        label=t_label_2,
        seriestype=:scatter,
        markersize=3,
        color=:red
    )

    mean_water_level = Statistics.mean(water_level_time_series)

    Plots.plot!(p, ylims=(mean_water_level-4.0, mean_water_level+5.0))

    return p

end

function _count_times_exceed_water_level(
    area_index::Int,
    water_level_threshold,
    df::DataFrames.DataFrame
)

    num_time = length(unique(df[!, :T]))

    cnt::Int = 0

    for j in 1:num_time

        i_first, i_final = GeneralGraphModule.decide_index_number(j-1)

        if df[i_first:i_final, :Z][area_index] > water_level_threshold
            cnt = cnt + 1
        end

    end

    return cnt

end

end
