export
    make_graph_non_dimensional_shear_stress,
    make_graph_effective_non_dimensional_shear_stress,
    make_graph_critical_non_dimensional_shear_stress

struct Plot_core_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_non_dimensional_shear_stress,
    time_schedule::DataFrames.DataFrame,
    target_hour::Int,
    japanese::Bool,
    x_vline::AbstractVector{<:AbstractFloat}
    )

    seriestype := :distance_line
    primary := true
    
    title --> GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )
    
    ylabel --> if japanese == true
        "無次元掃流力 (-)"
    else
        "Non Dimensional\nShear Stress (-)"
    end

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    x_vline --> x_vline

    primary := true
    
end


function _core_make_graph_non_dimensional_shear_stress(
    time_schedule,
    target_hour::Int;
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

    # distance_line(
    #     ;
    #     japanese=japanese,
    #     x_vline=[40.2, 24,4, 14.6]
    # )
    
    Plots.plot(
        Plot_core_non_dimensional_shear_stress(),
        time_schedule,
        target_hour,
        japanese,
        x_vline
    )
    
end

struct Plot_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τₛ = calc_non_dimensional_shear_stress(
            df_main.tuple[i],
            sediment_size,
            param,
            target_hour
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i], :I, target_hour
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:default)[j]

            (X, reverse(τₛ))
        end

    end

    primary := false

end


"""
無次元掃流力の縦断分布のグラフを作る。（平均粒径）
"""
function make_graph_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline        
    )
    
    Plots.plot!(
        p,
        Plot_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        target_df
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    spec_diameter::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τₛ = calc_non_dimensional_shear_stress(
            df_main.tuple[i],
            param,
            target_hour,
            spec_diameter
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i], :I, target_hour
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:default)[j]

            (X, reverse(τₛ))
        end

    end

    primary := false

end

"""
無次元掃流力の縦断分布のグラフを作る。（任意の粒径）
"""
function make_graph_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    spec_diameter::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline        
    )
    
    Plots.plot!(
        p,
        Plot_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        spec_diameter,
        target_df
    )

end

struct Plot_effective_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τₑₘ = calc_effective_non_dimensional_shear_stress(
            df_main.tuple[i],
            sediment_size,
            param,
            target_hour
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i], :I, target_hour
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:default)[j]

            (X, reverse(τₑₘ))
        end

    end

    primary := false

end


"""
無次元有効掃流力の縦断分布のグラフを作る（平均粒径）
"""
function make_graph_effective_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        target_df
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    spec_diameter_m::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τₑₘ = calc_effective_non_dimensional_shear_stress(
            df_main.tuple[i],
            sediment_size,
            param,
            target_hour,
            spec_diameter_m
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i], :I, target_hour
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:default)[j]

            (X, reverse(τₑₘ))
        end

    end

    primary := false

end

"""
無次元有効掃流力の縦断分布のグラフを作る（任意の粒径）
"""
function make_graph_effective_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,
    target_hour::Int,
    spec_diameter_m::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        spec_diameter_m,
        target_df
    )

end

struct Plot_critical_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_critical_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    seriestype := distance_line

    for (j, (i, label_string)) in zip(1:N, target_df)

        τ_cm = calc_critical_non_dimensional_shear_stress(
            df_main.tuple[i],
            sediment_size,
            param,
            target_hour
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i], :I, target_hour
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:default)[j]

            (X, reverse(τ_cm))
            
        end

    end

    primary := false

end

"""
無次元限界掃流力の縦断分布のグラフを作る（単一 平均粒径 岩垣式）
"""
function make_graph_critical_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,    
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_critical_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        target_df
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_critical_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    spec_diameter_m::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τ_ci = calc_critical_non_dimensional_shear_stress(
            df_main.tuple[i],
            sediment_size,
            spec_diameter_m,
            param,
            target_hour,
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i], :I, target_hour
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:default)[j]

            (X, reverse(τ_ci))
        end

    end

    primary := false

end

"""
無次元限界掃流力の縦断分布のグラフを作る（混合砂の任意の粒径）
"""
function make_graph_critical_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,    
    target_hour::Int,
    spec_diameter_m::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false
) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_critical_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        spec_diameter_m,
        target_df
    )

end

struct Plot_three_types_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_three_types_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    time_schedule,
    sediment_size,    
    target_hour::Int,
    spec_diameter_m::AbstractFloat,
    target_df::Int,
    japanese::Bool=false
    )

    i = target_df

    # 限界無次元掃流力
    τ_ci = calc_critical_non_dimensional_shear_stress(
        df_main.tuple[i],
        sediment_size,
        spec_diameter_m,
        param,
        target_hour,
    )

    # 標準無次元掃流力
    τₛ = calc_non_dimensional_shear_stress(
        df_main.tuple[i],
        param,
        target_hour,
        spec_diameter_m
    )

    # 有効無次元掃流力
    τₑₘ = calc_effective_non_dimensional_shear_stress(
        df_main.tuple[i],
        sediment_size,
        param,
        target_hour,
        spec_diameter_m
    )
    
    X  = average_neighbors_target_hour(
        df_main.tuple[i], :I, target_hour
    ) ./ 1000


    Plots.RecipesBase.@series begin

        primary := true
        label --> if japanese == true
            "限界"
        else
            "Critical"
        end
        
        linecolor := Plots.palette(:tab10)[1]
        linestyle := :dot

        (X, reverse(τ_ci))
        
    end

    Plots.RecipesBase.@series begin

        primary := true
        label --> if japanese == true
            "標準"
        else
            "Normal"
        end
        
        linecolor := Plots.palette(:tab10)[2]
        linestyle := :dash

        (X, reverse(τₛ))
        
    end

    Plots.RecipesBase.@series begin

        primary := true
        label --> if japanese == true
            "有効"
        else
            "Effective"
        end
        
        linecolor := Plots.palette(:tab10)[3]
        linestyle := :solid

        legend := :topright
        legend_title --> string(round(spec_diameter_m * 1000, sigdigits=3), " mm")

        (X, reverse(τₑₘ))
        
    end

    primary := false

    

end

"""

    make_graph_three_types_non_dimensional_shear_stress(
        df_main::Main_df,
        param::Param,
        time_schedule::DataFrames.DataFrame,
        sediment_size::DataFrames.DataFrame,    
        target_hour::Int,
        spec_diameter_m::AbstractFloat,
        target_df::Int;
        japanese::Bool=false,
        x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

特定の時間、任意の粒径階における限界・標準・有効無次元掃流力のグラフを作成する。
"""
function make_graph_three_types_non_dimensional_shear_stress(
    df_main::Main_df,
    param::Param,
    time_schedule::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,    
    target_hour::Int,
    spec_diameter_m::AbstractFloat,
    target_df::Int;
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

    p = _core_make_graph_non_dimensional_shear_stress(
        time_schedule,
        target_hour;
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_three_types_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        spec_diameter_m,
        target_df,
        japanese
    )

end
    
