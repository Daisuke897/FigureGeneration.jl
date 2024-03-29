export
    make_graph_non_dimensional_shear_stress,
    make_graph_effective_non_dimensional_shear_stress,
    make_graph_critical_non_dimensional_shear_stress

struct Plot_core_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_core_non_dimensional_shear_stress,
    japanese::Bool,
    x_vline::AbstractVector{<:AbstractFloat}
    )

    seriestype := :distance_line
    primary := true

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
    ;japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

    # distance_line(
    #     ;
    #     japanese=japanese,
    #     x_vline=[40.2, 24,4, 14.6]
    # )

    Plots.plot(
        Plot_core_non_dimensional_shear_stress(),
        japanese,
        x_vline
    )

end

struct Plot_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            linecolor := Plots.palette(:Set1_9)[j]

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
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,    
        target_hour,
        target_df,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            linecolor := Plots.palette(:Set1_9)[j]

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
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,
        target_hour,
        spec_diameter,
        target_df,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τₛ = calc_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            param,
            each_year_timing,
            year_first,
            year_last,
            spec_diameter
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

            (X, reverse(τₛ))
        end

    end

    primary := false

end

"""
複数年の（通常）無次元掃流力の平均値のグラフを作成する。（任意の粒径）
"""
function make_graph_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_non_dimensional_shear_stress(),
        df_main,
        param,
        each_year_timing,
        year_first,
        year_last,
        spec_diameter,
        target_df,
        title = if japanese == true
            string("無次元掃流力 ", year_first, " - ", year_last)
        else
            string("Non dimensional shear stress ", year_first, " - ", year_last)
        end,
        legend_title = if spec_diameter * 1000 >= 100.0 && spec_diameter * 1000 % 1 == 0.0
            string(Int(spec_diameter * 1000), " mm")
        else
            string(round(spec_diameter * 1000, sigdigits=3), " mm")
        end
    )

end

struct Plot_effective_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            linecolor := Plots.palette(:Set1_9)[j]

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
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,
        target_hour,
        target_df,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            linecolor := Plots.palette(:Set1_9)[j]

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
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,
        target_hour,
        spec_diameter_m,
        target_df,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            sediment_size,
            param,
            each_year_timing,
            year_first,
            year_last,
            spec_diameter
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

            (X, reverse(τₑ))
        end

    end

    primary := false

end

"""
複数年の有効無次元掃流力の年平均値のグラフを作成する。（任意の粒径）
"""
function make_graph_effective_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        spec_diameter,
        target_df,
        title = if japanese == true
            string("有効無次元掃流力 ", year_first, " - ", year_last)
        else
            string("Effective non dimensional shear stress ", year_first, " - ", year_last)
        end,
        legend_title = if spec_diameter * 1000 >= 100.0 && spec_diameter * 1000 % 1 == 0.0
            string(Int(spec_diameter * 1000), " mm")
        else
            string(round(spec_diameter * 1000, sigdigits=3), " mm")
        end
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    sediment_size::DataFrames.AbstractDataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_df::Int
    )

    for i in axes(sediment_size, 1)

        spec_diameter = sediment_size[i, 2]

        τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[index_df],
            sediment_size,
            param,
            each_year_timing,
            year_first,
            year_last,
            spec_diameter
        )

        X = reverse(
            average_neighbors_target_hour(
                df_main.tuple[index_df],
                :I,
                each_year_timing.dict[year_first][1]
            ) ./ 1000
        )

        s_label = if i == 1
            Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        Plots.RecipesBase.@series begin

            primary := true
            label := s_label
            linecolor := Plots.palette(:tab20)[i]
            yscale := :log10
            ylims  := (0.00001, 100.0)

            (X, τₑ)
        end

    end

    primary := false

end

"""
複数年の有効無次元掃流力の年平均値のグラフを作成する。（すべての粒径階）
"""
function make_graph_effective_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_df::Int,
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
)

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    title_string = string(year_first, " - ", year_last)

    legend_t = if japanese
        "粒径 (mm)"
    else
        "Size (mm)"
    end

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        index_df,
        title=title_string,
        legend_title = legend_t
    )

    return p

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    sediment_size::DataFrames.AbstractDataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_df::Int
    )

    for i in axes(sediment_size, 1)

        spec_diameter = sediment_size[i, 2]

        τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[index_df],
            sediment_size,
            param,
            each_year_timing,
            year_first,
            year_last,
            spec_diameter
        )

        τₑ_max = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_max.tuple[index_df],
            sediment_size,
            param,
            each_year_timing,
            year_first,
            year_last,
            spec_diameter
        )

        τₑ_min = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_min.tuple[index_df],
            sediment_size,
            param,
            each_year_timing,
            year_first,
            year_last,
            spec_diameter
        )

        X = reverse(
            average_neighbors_target_hour(
                df_main.tuple[index_df],
                :I,
                each_year_timing.dict[year_first][1]
            ) ./ 1000
        )

        s_label = if i == 1
            Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end

        # println(τₑ .- τₑ_max)
        # println(τₑ_min .- τₑ)

        Plots.RecipesBase.@series begin

            primary := true
            label := s_label
            linecolor := Plots.palette(:tab20)[i]
            yscale := :log10
            ylims  := (0.00001, 100.0)
            ribbon := (
                τₑ .- τₑ_max,
                τₑ_min .- τₑ
            )
            fillcolor := Plots.palette(:tab20)[i]
            fillalpha := 0.3

            (X, τₑ)
        end

    end

    primary := false

end

"""
複数年の有効無次元掃流力の年平均値のグラフを作成する。（すべての粒径階・レンジ付き）
"""
function make_graph_effective_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_df::Int,
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
)

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    title_string = string(year_first, " - ", year_last)

    legend_t = if japanese
        "粒径 (mm)"
    else
        "Size (mm)"
    end

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        df_max,
        df_min,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        index_df,
        title=title_string,
        legend_title = legend_t
    )

    return p

end


Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )

        X  = average_neighbors_target_hour(
            df_main.tuple[i],
            :I,
            each_year_timing.dict[year_first][1]
        ) ./ 1000

        reverse!(X)

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]

            (X, τₑ)
        end

    end

    primary := false

end

"""
複数年の有効無次元掃流力の年平均値のグラフを作成する。（平均粒径）
"""
function plot_effective_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        target_df,
        title = string(year_first, " - ", year_last),
        ylabel=if japanese
            "無次元有効掃流力 (-)"
        else
            "Non dimensional\neffective shear stress (-)"
        end
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_df_base::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    τₑ_base = calc_effective_non_dimensional_shear_stress_yearly_mean(
        df_main.tuple[index_df_base],
        sediment_size,
        param,
        year_first,
        year_last,
        each_year_timing
    )

    τₑ_max_base = calc_effective_non_dimensional_shear_stress_yearly_mean(
        df_max.tuple[index_df_base],
        sediment_size,
        param,
        year_first,
        year_last,
        each_year_timing
    )

    τₑ_min_base = calc_effective_non_dimensional_shear_stress_yearly_mean(
        df_min.tuple[index_df_base],
        sediment_size,
        param,
        year_first,
        year_last,
        each_year_timing
    )

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )

        τₑ_max = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_max.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )

        τₑ_min = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_min.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )

        τₑ .= ((τₑ ./ τₑ_base) .- 1) * 100
        τₑ_max .= ((τₑ_max ./ τₑ_max_base) .- 1) * 100
        τₑ_min .= ((τₑ_min ./ τₑ_min_base) .- 1) * 100

        X  = average_neighbors_target_hour(
            df_main.tuple[i],
            :I,
            each_year_timing.dict[year_first][1]
        ) ./ 1000

        reverse!(X)

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]
            ribbon := (
                τₑ .- τₑ_min,
                τₑ_max .- τₑ
            )
            fillcolor := Plots.palette(:Set1_9)[j]
            fillalpha := 0.3

            (X, τₑ)
        end

    end

    primary := false

end


"""
複数年の有効無次元掃流力の年平均値の条件による変化率のグラフを作成する。
（平均粒径）
"""
function plot_variation_effective_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    index_df_base::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.hline!(
        [0],
        primary=false,
        linecolor=:black,
        linestyle=:dot,
        linewidth=2
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        df_max,
        df_min,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        index_df_base,
        target_df,
        ylims=(-100,100),
        ylabel=if japanese
            "変化率 (%)"
        else
            "Rate of variation (%)"
        end,
        title = string(year_first, " - ", year_last)
    )

    return p

end

Plots.RecipesBase.@recipe function f(
    ::Plot_effective_non_dimensional_shear_stress,
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for j in 1:N

        i = target_df[j][1]
        label_string = target_df[j][2]

        τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )
        τₑ_max = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_max.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )
        τₑ_min = calc_effective_non_dimensional_shear_stress_yearly_mean(
            df_min.tuple[i],
            sediment_size,
            param,
            year_first,
            year_last,
            each_year_timing
        )


        X  = average_neighbors_target_hour(
            df_main.tuple[i],
            :I,
            each_year_timing.dict[year_first][1]
        ) ./ 1000

        reverse!(X)

        Plots.RecipesBase.@series begin

            primary := true
            label := label_string
            linecolor := Plots.palette(:Set1_9)[j]
            ribbon := (
                τₑ .- τₑ_min,
                τₑ_max .- τₑ
            )
            fillcolor := Plots.palette(:Set1_9)[j]
            fillalpha := 0.3

            (X, τₑ)
        end

    end

    primary := false

end

"""
複数年の有効無次元掃流力の年平均値のグラフを作成する。（平均粒径）
レンジ付き
"""
function plot_effective_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    df_max::Main_df,
    df_min::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_effective_non_dimensional_shear_stress(),
        df_main,
        df_max,
        df_min,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        target_df,
        title = string(year_first, " - ", year_last),
        ylabel=if japanese
            "無次元有効掃流力 (-)"
        else
            "Non dimensional\neffective shear stress (-)"
        end
    )

end

struct Plot_critical_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_critical_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            linecolor := Plots.palette(:Set1_9)[j]

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
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_critical_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,    
        target_hour,
        target_df,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_critical_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            linecolor := Plots.palette(:Set1_9)[j]

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
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_critical_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,    
        target_hour,
        spec_diameter_m,
        target_df,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_critical_non_dimensional_shear_stress,
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}}
    ) where {N}

    for (j, (i, label_string)) in zip(1:N, target_df)

        τ_c = calc_critical_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            sediment_size,
            param,
            each_year_timing,
            year_first,
            year_last,    
            spec_diameter
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

            (X, reverse(τ_c))
        end

    end

    primary := false

end

"""
複数年の限界無次元掃流力の年平均値のグラフを作成する。（任意の粒径）
"""
function make_graph_critical_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,    
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline        
    )
    
    Plots.plot!(
        p,
        Plot_critical_non_dimensional_shear_stress(),
        df_main,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        spec_diameter,
        target_df,
        title = if japanese == true
            string("限界無次元掃流力 ", year_first, " - ", year_last)
        else
            string("Critical non dimensional shear stress ", year_first, " - ", year_last)
        end,
        legend_title = if spec_diameter * 1000 >= 100.0 && spec_diameter * 1000 % 1 == 0.0
            string(Int(spec_diameter * 1000), " mm")
        else
            string(round(spec_diameter * 1000, sigdigits=3), " mm")
        end
    )

end

struct Plot_three_types_non_dimensional_shear_stress end

Plots.RecipesBase.@recipe function f(
    ::Plot_three_types_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
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
            "Standard"
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
        legend_title --> if spec_diameter_m * 1000 >= 100.0 && spec_diameter_m * 1000 % 1 == 0.0
            string(Int(spec_diameter_m * 1000), " mm")
        else
            string(round(spec_diameter_m * 1000, sigdigits=3), " mm")
        end

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
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_three_types_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,    
        target_hour,
        spec_diameter_m,
        target_df,
        japanese,
        title = GeneralGraphModule.making_time_series_title(
            "",
            target_hour,
            target_hour * 3600,
            time_schedule
        )
    )

end

Plots.RecipesBase.@recipe function f(
    ::Plot_three_types_non_dimensional_shear_stress,
    df_main::Main_df,
    param::Param,
    sediment_size::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter_m::AbstractFloat,
    target_df::Int,
    japanese::Bool=false
    )

    i = target_df

    # 平均 限界無次元掃流力
    τ_c = calc_critical_non_dimensional_shear_stress_yearly_mean(
        df_main.tuple[i],
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,    
        spec_diameter_m
    )

    # 平均 標準無次元掃流力
    τₛ = calc_non_dimensional_shear_stress_yearly_mean(
        df_main.tuple[i],
        param,
        each_year_timing,
        year_first,
        year_last,    
        spec_diameter_m
    )

    # 平均 有効無次元掃流力
    τₑ = calc_effective_non_dimensional_shear_stress_yearly_mean(
        df_main.tuple[i],
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,    
        spec_diameter_m
    )
    
    X  = average_neighbors_target_hour(
        df_main.tuple[i], :I, each_year_timing.dict[year_first][1]
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

        (X, reverse(τ_c))
        
    end

    Plots.RecipesBase.@series begin

        primary := true
        label --> if japanese == true
            "標準"
        else
            "Standard"
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
        legend_title --> if spec_diameter_m * 1000 >= 100.0 && spec_diameter_m * 1000 % 1 == 0.0
            string(Int(spec_diameter_m * 1000), " mm")
        else
            string(round(spec_diameter_m * 1000, sigdigits=3), " mm")
        end

        (X, reverse(τₑ))
        
    end

    primary := false

end

"""
複数年の期間における平均の限界・標準・有効無次元掃流力のグラフを作成する。
"""
function make_graph_three_types_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    param::Param,
    sediment_size::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter_m::AbstractFloat,
    target_df::Int;
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    )

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline
    )

    Plots.plot!(
        p,
        Plot_three_types_non_dimensional_shear_stress(),
        df_main,
        param,
        sediment_size,
        each_year_timing,
        year_first,
        year_last,
        spec_diameter_m,
        target_df,
        japanese=japanese,
        title = if japanese == true
            string("無次元掃流力 ", year_first, " - ", year_last)
        else
            string("Non dimensional shear stress ", year_first, " - ", year_last)
        end        
    )

    return p
    
end

# 複数年の無次元掃流力と限界無次元掃流力の平均値の比率のグラフを作る

struct Plot_ratio_critical_standard_non_dimensional_shear_stress_yearly_mean end

Plots.RecipesBase.@recipe function f(
    ::Plot_ratio_critical_standard_non_dimensional_shear_stress_yearly_mean,
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::NTuple{N, Tuple{Int, <:AbstractString}},
    ::Val{N},
    japanese::Bool
    ) where {N}

    title --> if japanese == true
        string(year_first, " - ", year_last)
    else
        string(year_first, " - ", year_last)
    end

    xlabel --> if japanese == true
        "河口からの距離 (km)"
    else
        "Distance from the estuary (km)"
    end

    ylabel --> if japanese == true
        "標準無次元掃流力に対する\n有効無次元掃流力の比率 (-)"
    else
        "Ratio of standard to critical\nnon dimensional\nshear stress (-)"
    end

    legend_title --> if spec_diameter * 1000 >= 100.0 && spec_diameter * 1000 % 1 == 0.0
        string(Int(spec_diameter * 1000), " mm")
    else
        string(round(spec_diameter * 1000, sigdigits=3), " mm")
    end

    for (j, (i, label_string)) in zip(1:N, target_df)

        ratio_τ = calc_ratio_critical_standard_non_dimensional_shear_stress_yearly_mean(
            df_main.tuple[i],
            sediment_size,    
            param,
            each_year_timing,
            year_first,
            year_last,    
            spec_diameter
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

            (X, reverse(ratio_τ))
        end

    end

    Plots.RecipesBase.@series begin

        seriestype := :hline
        line := :black
        linestyle --> :dash
        linewidth := 1
        primary := false

        ([0.0], [1.0])
    end

    ylims --> (0.0, 2.0)

    primary := false

end

function make_graph_ratio_critical_standard_non_dimensional_shear_stress_yearly_mean(
    df_main::Main_df,
    sediment_size::DataFrames.DataFrame,    
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    spec_diameter::AbstractFloat,
    target_df::Vararg{Tuple{Int, <:AbstractString}, N};
    japanese::Bool=false,
    x_vline::AbstractVector{<:AbstractFloat}=[14.6, 24.4, 40.2]
    ) where {N}

    p = _core_make_graph_non_dimensional_shear_stress(
        japanese=japanese,
        x_vline=x_vline        
    )

    Plots.plot!(
        p,
        Plot_ratio_critical_standard_non_dimensional_shear_stress_yearly_mean(),
        df_main,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        year_last,
        spec_diameter,
        target_df,
        Val(N),
        japanese,
    )

end


