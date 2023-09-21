struct Plot_core_friction_velocity end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_friction_velocity,
    japanese::Bool,
    x_vline::AbstractVector{<:AbstractFloat}
    )

    seriestype := :distance_line
    primary := true
    
    ylabel --> if japanese == true
        "摩擦速度 (m/s)"
    else
        "Friction velocity (m/s)"
    end

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    x_vline --> x_vline

    primary := true
    
end

function _core_make_graph_friction_velocity(
    ;japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

    Plots.plot(
        Plot_core_friction_velocity(),
        japanese,
        x_vline
    )
    
end

struct Plot_friction_velocity end

Plots.RecipesBase.@recipe function f(
    ::Plot_friction_velocity,
    df_main::Main_df,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        uₛ = calc_friction_velocity_yearly_mean(
            df_main.tuple[i],
            param,
            each_year_timing,
            year_first,
            year_last
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[i],
            :I,
            each_year_timing.dict[year_first][1]
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]

            (X, reverse(uₛ))
        end

    end

    primary := false

end

"""
複数年の（通常）摩擦速度の平均値のグラフを作成する。
"""
function make_graph_friction_velocity_yearly_mean(
    df_main::Main_df,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}


    p = _core_make_graph_friction_velocity(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_friction_velocity(),
        df_main,
        param,
        each_year_timing,
        year_first,
        year_last,
        target_df,
        Val(N)
    )

    return p
    
end
