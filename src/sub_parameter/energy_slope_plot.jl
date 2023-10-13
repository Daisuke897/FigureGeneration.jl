struct Plot_core_energy_slope end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_energy_slope,
    japanese::Bool,
    x_vline::AbstractVector{<:AbstractFloat}
    )

    seriestype := :distance_line
    primary := true
    
    ylabel --> if japanese == true
        "エネルギー勾配 (-)"
    else
        "Energy slope (-)"
    end

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    x_vline --> x_vline

    ylims := (0, 0.01)

    primary := true
    
end

function _core_make_graph_energy_slope(
    ;japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

    Plots.plot(
        Plot_core_energy_slope(),
        japanese,
        x_vline
    )
    
end


struct Plot_energy_slope end

Plots.RecipesBase.@recipe function f(
    ::Plot_energy_slope,
    df_main::Main_df,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N}
    ) where {N}

    for i in 1:N

        i_e = calc_energy_slope_yearly_mean(
            df_main.tuple[target_df[i][1]],
            param,
            each_year_timing,
            year_first,
            year_last
        )
        
        X  = average_neighbors_target_hour(
            df_main.tuple[target_df[i][1]],
            :I,
            each_year_timing.dict[year_first][1]
        ) ./ 1000

        Plots.RecipesBase.@series begin

            primary := true
            label := target_df[i][2]
            linecolor := Plots.palette(:Set1_9)[target_df[i][1]]

            (X, reverse(i_e))
        end

    end

    primary := false

end


"""
複数年のエネルギー勾配の平均値のグラフを作成する。
"""
function make_graph_energy_slope_yearly_mean(
    df_main::Main_df,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_energy_slope(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_energy_slope(),
        df_main,
        param,
        each_year_timing,
        year_first,
        year_last,
        target_df,
        Val(N),
        ylims=(1e-5, 1e-2),
        yscale=:log10,
        legend=:bottomleft
    )

    return p
    
end
