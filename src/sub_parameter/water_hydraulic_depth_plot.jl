# 径深についてグラフを作る

struct Plot_core_water_hydraulic_depth end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_water_hydraulic_depth,
    japanese::Bool,
    x_vline::AbstractVector{<:AbstractFloat}
    )

    seriestype := :distance_line
    primary := true
    
    ylabel --> if japanese == true
        "径深 (m)"
    else
        "Water hydraulic depth (m)"
    end

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    x_vline --> x_vline

    primary := true
    
end

struct Plot_water_hydraulic_depth end

Plots.RecipesBase.@recipe function f(
    ::Plot_water_hydraulic_depth,
    df_main::Main_df,
    target_hour::Int,
    ::Val{N},
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        water_hydraulic_depth = calc_water_hydraulic_depth(
            df_main.tuple[i],
            targer_hour
        )

        start_index, finish_index =
            GeneralGraphModule.decide_index_number(target_hour)

        len_num = finish_index - start_index + 1
        
        X = [0.2*(i-1) for i in 1:len_num]
        
        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]

            (X, reverse(water_hydraulic_depth))
        end

    end

    primary := false

end

function make_graph_water_hydraulic_depth(
    df_main::Main_df,
    time_schedule,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
) where {N}


    p = Plots.plot(
        Plot_core_water_hydraulic_depth(),
        japanese,
        x_vline
    )

    Plots.plot!(
        p,
        Plot_water_hydraulic_depth(),
        df_main,
        target_hour,
        Val(N),
        target_df,
        title = string(
            GeneralGraphModule.making_time_series_title(
                "",
                target_hour,
                time_schedule
            ),
            "Discharge ",
            df_vararg[1][start_index, :Qw],
            " m³/s"
        )
    )

    return p

end

Plots.RecipesBase.@recipe function f(
    ::Plot_water_hydraulic_depth,
    df_main::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    ::Val{N},
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        water_hydraulic_depth = calc_water_hydraulic_depth_yearly_mean(
            df_main.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        start_index, finish_index =
            GeneralGraphModule.decide_index_number(
                each_year_timing.dict[year_first][1]
            )

        len_num = finish_index - start_index + 1
        
        X = [0.2*(i-1) for i in 1:len_num]
        
        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]

            (X, reverse(water_hydraulic_depth))
        end

    end

    primary := false

end

function make_graph_water_hydraulic_depth_yearly_mean(
    df_main::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,    
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
) where {N}


    p = Plots.plot(
        Plot_core_water_hydraulic_depth(),
        japanese,
        x_vline
    )

    Plots.plot!(
        p,
        Plot_water_hydraulic_depth(),
        df_main,
        each_year_timing,
        year_first,
        year_last,
        Val(N),
        target_df,
        title = if japanese == true
            string("径深 ", year_first, " - ", year_last)
        else
            string("Water hydraulic depth ", year_first, " - ", year_last)
        end
    )

    return p

end
