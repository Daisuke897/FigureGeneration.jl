export
    make_graph_non_dimensional_shear_stress,
    make_graph_effective_non_dimensional_shear_stress,
    make_graph_critical_non_dimensional_shear_stress

struct Plot_core_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_non_dimensional_shear_stress,
    time_schedule::DataFrames.DataFrame,
    target_hour::Int,
    japanese::Bool=false
    )

    title --> GeneralGraphModule.making_time_series_title(
        "",
        target_hour,
        target_hour * 3600,
        time_schedule
    )

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    ylabel --> if japanese == true
        "無次元掃流力 (-)"
    else
        "Non Dimensional\nShear Stress (-)"
    end

    primary := false
    xlims  --> (0, 77.8)
    xticks --> [0, 20, 40, 60, 77.8]
    xflip  :=  true
    legend --> :topright
    palette--> :default

    Plots.RecipesBase.@series begin

        seriestype := :vline
        primary := false
        line := :black
        linestyle --> :dash
        linewidth := 1

        [40.2, 24,4, 14.6]

    end

    ()

end


function _core_make_graph_non_dimensional_shear_stress(
    time_schedule,
    target_hour::Int;
    japanese::Bool=false
)

    Plots.plot(
        Plot_core_non_dimensional_shear_stress(),
        time_schedule,
        target_hour,
        japanese = japanese
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
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    japanese::Bool=false
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
    ()

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
        japanese=japanese
    )
    
    Plots.plot!(
        p,
        Plot_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        target_df,
        japanese=japanese
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
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    japanese::Bool=false
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
    ()

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
        japanese=japanese
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
        target_df,
        japanese=japanese
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
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    japanese::Bool=false
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
    ()

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
        japanese=japanese
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        target_df,
        japanese=japanese
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
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    japanese::Bool=false
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
    ()

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
        japanese=japanese
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
        target_df,
        japanese=japanese
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
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    japanese::Bool=false
    ) where {N}

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
    ()

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
        japanese=japanese
    )

    Plots.plot!(
        p,
        Plot_critical_non_dimensional_shear_stress(),
        df_main,
        param,
        time_schedule,
        sediment_size,    
        target_hour,
        target_df,
        japanese=japanese
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
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    japanese::Bool=false
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
    ()

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
        japanese=japanese
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
        target_df,
        japanese=japanese
    )

end
