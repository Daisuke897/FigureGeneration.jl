# 水位についてグラフを作る

struct Plot_core_water_level end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_water_level,
    japanese::Bool,
    x_vline::AbstractVector{<:AbstractFloat}
    )

    seriestype := :distance_line
    primary := true

    ylabel --> if japanese == true
        "水位 (T.P. m)"
    else
        "Water level (T.P. m)"
    end

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    x_vline --> x_vline

    primary := true

end

struct Plot_water_level end

Plots.RecipesBase.@recipe function f(
    ::Plot_water_level,
    df_main::Main_df,
    target_hour::Int,
    ::Val{N},
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        water_level = calc_water_level(
            df_main.tuple[i],
            target_hour
        )

        start_index, finish_index =
            GeneralGraphModule.decide_index_number(target_hour)

        len_num = finish_index - start_index + 1

        X = reverse!(collect(range(start=0.0, step=0.2, length=len_num)))

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]

            (X, water_level)
        end

    end

    primary := false

end

function make_graph_water_level(
    df_main::Main_df,
    target_hour::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
) where {N}


    p = Plots.plot(
        Plot_core_water_level(),
        japanese,
        x_vline
    )

    Plots.plot!(
        p,
        Plot_water_level(),
        df_main,
        target_hour,
        Val(N),
        target_df
    )

    return p

end

Plots.RecipesBase.@recipe function f(
    ::Plot_water_level,
    df_main::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    flow_size::Int,
    ::Val{N},
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        water_level = calc_water_level_yearly_mean(
            df_main.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        X = reverse!(collect(range(start=0.0, step=0.2, length=flow_size)))

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]
            linewidth := 1

            (X, water_level)
        end

    end

    primary := false

end

function make_graph_water_level_yearly_mean(
    df_main::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
) where {N}


    p = Plots.plot(
        Plot_core_water_level(),
        japanese,
        x_vline
    )

    Plots.plot!(
        p,
        Plot_water_level(),
        df_main,
        each_year_timing,
        year_first,
        year_last,
        flow_size,
        Val(N),
        target_df,
        title = string(year_first, " - ", year_last)
    )

    return p

end

Plots.RecipesBase.@recipe function f(
    ::Plot_water_level,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    flow_size::Int,
    ::Val{N},
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    X = reverse!(collect(range(start=0.0, step=0.2, length=flow_size)))

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        water_level = calc_water_level_yearly_mean(
            df_main.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        water_level_max = calc_water_level_yearly_mean(
            df_max.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        water_level_min = calc_water_level_yearly_mean(
            df_min.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )



        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]
            ribbon := (
                water_level .- water_level_min,
                water_level_max .- water_level
            )
            fillcolor := Plots.palette(:Set1_9)[j]
            fillalpha := 0.3
            linewidth := 1

            (X, water_level)
        end

    end

    primary := false

end

function make_graph_water_level_yearly_mean(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
) where {N}


    p = Plots.plot(
        Plot_core_water_level(),
        japanese,
        x_vline
    )

    Plots.plot!(
        p,
        Plot_water_level(),
        df_main,
        df_max,
        df_min,
        each_year_timing,
        year_first,
        year_last,
        flow_size,
        Val(N),
        target_df,
        title = string(year_first, " - ", year_last),
        ylims=(-5, 85)
    )

    return p

end

Plots.RecipesBase.@recipe function f(
    ::Plot_water_level,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    flow_size::Int,
    ::Val{N},
    index_base_df::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    X = reverse!(collect(range(start=0.0, step=0.2, length=flow_size)))

    water_level_base = calc_water_level_yearly_mean(
        df_main.tuple[index_base_df],
        each_year_timing,
        year_first,
        year_last
    )

    water_level_max_base = calc_water_level_yearly_mean(
        df_max.tuple[index_base_df],
        each_year_timing,
        year_first,
        year_last
    )

    water_level_min_base = calc_water_level_yearly_mean(
        df_min.tuple[index_base_df],
        each_year_timing,
        year_first,
        year_last
    )

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        water_level = calc_water_level_yearly_mean(
            df_main.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        water_level_max = calc_water_level_yearly_mean(
            df_max.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        water_level_min = calc_water_level_yearly_mean(
            df_min.tuple[i],
            each_year_timing,
            year_first,
            year_last
        )

        water_level .=
            water_level .- water_level_base

        water_level_max .=
            water_level_max .- water_level_max_base

        water_level_min .=
            water_level_min .- water_level_min_base

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]
            ribbon := (
                water_level .- water_level_min,
                water_level_max .- water_level
            )
            fillcolor := Plots.palette(:Set1_9)[j]
            fillalpha := 0.3
            linewidth := 1

            (X, water_level)
        end

    end

    primary := false

end

function make_graph_water_level_yearly_mean_variation(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_base_df::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    flow_size::Int=390,
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
) where {N}


    p = Plots.plot(
        Plot_core_water_level(),
        japanese,
        x_vline
    )

    Plots.hline!(
        p,
        [0],
        linestyle=:dot,
        linecolor=:black,
        linewidth=1,
        primary=false
    )

    Plots.plot!(
        p,
        Plot_water_level(),
        df_main,
        df_max,
        df_min,
        each_year_timing,
        year_first,
        year_last,
        flow_size,
        Val(N),
        index_base_df,
        target_df,
        title = string(year_first, " - ", year_last),
        ylims=(-2, 2),
        ylabel = if japanese
            "変化量 (m)"
        else
            "Variation (m)"
        end
    )

    return p

end
