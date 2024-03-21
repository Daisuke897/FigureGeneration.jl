function make_graph_particle_suspended_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_particle_suspended_volume_each_year(
        area_index,
        data_file,
        index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_particle_suspended_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    suspended_sediment =
        particle_suspended_sediment_volume_each_year(
            area_index,
            390,
            data_file.tuple[index_df],
            each_year_timing,
            1965,
            1999,
            sediment_size
        )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ",
            round(area_km, digits=2),
            " km"
        )
        y_label = "浮遊砂量 (10^6 m³/年)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2),
            " km from the estuary"
        )
        y_label = "Suspended sediment load\n(10⁶ m³/year)"
        l_title = "Size (mm)"
    end

    suspended_sediment .= suspended_sediment ./ 10^6

    p = StatsPlots.groupedbar(
        1965:1999,
        suspended_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(0, 15),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        # legend_font_pointsize=10,
        # legend_title_font_pointsize=10,
        # tickfontsize=12,
        # guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=:tab20
    )

    return p

end

function make_graph_particle_suspended_percentage_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_particle_suspended_percentage_each_year(
        area_index,
        data_file,
        index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_particle_suspended_percentage_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    suspended_sediment =
        particle_suspended_sediment_volume_each_year(
            area_index,
            390,
            data_file.tuple[index_df],
            each_year_timing,
            1965,
            1999,
            sediment_size
        )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ",
            round(area_km, digits=2),
            " km"
        )
        y_label = "割合 (%)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2),
            " km from the estuary"
        )
        y_label = "Percentage (%)"
        l_title = "Size (mm)"
    end

    for i in axes(suspended_sediment, 1)

        temp_sum = sum(view(suspended_sediment, i, :))

        suspended_sediment[i, :] .= suspended_sediment[i, :] ./ temp_sum * 100

    end

    p = StatsPlots.groupedbar(
        1965:1999,
        suspended_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(0, 100),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        # legend_font_pointsize=10,
        # legend_title_font_pointsize=10,
        # tickfontsize=12,
        # guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=:tab20
    )

    return p

end

function make_graph_particle_suspended_percentage_point_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    base_index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_particle_suspended_percentage_point_each_year(
        area_index,
        data_file,
        index_df,
        base_index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_particle_suspended_percentage_point_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    base_index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    suspended_sediment =
        particle_suspended_sediment_volume_each_year(
            area_index,
            390,
            data_file.tuple[index_df],
            each_year_timing,
            1965,
            1999,
            sediment_size
        )

    suspended_sediment_base =
        particle_suspended_sediment_volume_each_year(
            area_index,
            390,
            data_file.tuple[base_index_df],
            each_year_timing,
            1965,
            1999,
            sediment_size
        )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ",
            round(area_km, digits=2),
            " km"
        )
        y_label = "パーセントポイント (%pt)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2),
            " km from the estuary"
        )
        y_label = "Percentage point (%pt)"
        l_title = "Size (mm)"
    end

    for i in axes(suspended_sediment, 1)

        temp_sum = sum(view(suspended_sediment, i, :))

        suspended_sediment[i, :] .= suspended_sediment[i, :] ./ temp_sum * 100

    end

    for i in axes(suspended_sediment_base, 1)

        temp_sum = sum(view(suspended_sediment_base, i, :))

        suspended_sediment_base[i, :] .= suspended_sediment_base[i, :] ./ temp_sum * 100

    end

    suspended_sediment .= suspended_sediment .- suspended_sediment_base

    p = StatsPlots.groupedbar(
        1965:1999,
        suspended_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(-5, 5),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        # legend_font_pointsize=10,
        # legend_title_font_pointsize=10,
        # tickfontsize=12,
        # guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=:tab20
    )

    return p

end

function make_graph_particle_suspended_volume_each_year_with_average_line(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64,
    first_year::Int,
    final_year::Int,
    mid_year::Int;
    added_title::String="",
    japanese::Bool=false
    )


    p = make_graph_particle_suspended_volume_each_year(
        area_index,
        data_file,
        index_df,
        each_year_timing,
        sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    vec_suspended = suspended_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df], 
        each_year_timing,
        1965,
        1999
    )

    plot!(
        p,
        collect(first_year:mid_year-1),
        [mean(vec_suspended[first_year-first_year+1:(mid_year-1)-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:darksalmon,
        label=string("Average \nbefore \n", (mid_year-1))
    )

    plot!(
        p,
        collect(mid_year:final_year),
        [mean(vec_suspended[mid_year-first_year+1:final_year-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:deeppink,
        label=string("Average \nafter \n", mid_year)
    )
    
    return p

end

function make_graph_condition_change_suspended_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df_base::Int,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    variation_suspended = particle_suspended_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df],
        each_year_timing,
        1965,
        1999,
        sediment_size
    ) - particle_suspended_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df_base],
        each_year_timing,
        1965,
        1999,
        sediment_size
    )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ", 
            round(area_km, digits=2), 
            " km"
        )
        y_label = "浮遊砂の変動量 (m³/年)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2), 
            " km from the estuary"
        )
        y_label = "Variation in suspended sediment load (m³/year)"
        l_title = "Size (mm)"
    end

    p = vline([1975], line=:black, label="", linestyle=:dot, linewidth=1)

    groupedbar!(
        p,
        collect(1965:1999),
        variation_suspended,
        bar_position = :stack,
        legend = :outerright,
        ylims=(-4e6, 1e6),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        legend_font_pointsize=10,
        legend_title_font_pointsize=10,
        tickfontsize=12,
        guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=palette(:vik, size(sediment_size, 1)+2)
    )

end

function make_graph_condition_change_suspended_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df_base::Int,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String,
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_condition_change_suspended_volume_each_year(
        area_index,
        data_file,
        index_df_base,
        index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_condition_change_suspended_volume_each_year_with_average_line(
    area_index::Int,
    data_file::Main_df,
    index_df_base::Int,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64,
    first_year::Int,
    final_year::Int,
    mid_year::Int;
    added_title::String,
    japanese::Bool=false
    )


    p = make_graph_condition_change_suspended_volume_each_year(
        area_index,
        data_file,
        index_df_base,
        index_df,
        each_year_timing,
        sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )


    vec_suspended = suspended_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df], 
        each_year_timing,
        1965,
        1999
    ) - suspended_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df_base], 
        each_year_timing,
        1965,
        1999
    ) 

    plot!(
        p,
        collect(first_year:mid_year-1),
        [mean(vec_suspended[first_year-first_year+1:(mid_year-1)-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:darksalmon,
        label=string("Average \nbefore \n", (mid_year-1))
    )

    plot!(
        p,
        collect(mid_year:final_year),
        [mean(vec_suspended[mid_year-first_year+1:final_year-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:deeppink,
        label=string("Average \nafter \n", mid_year)
    )

    return p

end

function make_graph_particle_bedload_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_particle_bedload_volume_each_year(
        area_index,
        data_file,
        index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_particle_bedload_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    bedload_sediment = particle_bedload_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df],
        each_year_timing,
        1965,
        1999,
        sediment_size
    )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ",
            round(area_km, digits=2),
            " km"
        )
        y_label = "掃流砂量 (10^3 m³/年)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2),
            " km from the estuary"
        )
        y_label = "Bedload (10³ m³/year)"
        l_title = "Size (mm)"
    end

    bedload_sediment .= bedload_sediment ./ 10^3

    p = StatsPlots.groupedbar(
        1965:1999,
        bedload_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(0, 60),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        # legend_font_pointsize=10,
        # legend_title_font_pointsize=10,
        # tickfontsize=12,
        # guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=:tab20
    )

    return p

end

function make_graph_particle_bedload_percentage_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_particle_bedload_percentage_each_year(
        area_index,
        data_file,
        index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_particle_bedload_percentage_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    bedload_sediment = particle_bedload_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df],
        each_year_timing,
        1965,
        1999,
        sediment_size
    )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ",
            round(area_km, digits=2),
            " km"
        )
        y_label = "割合 (%)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2),
            " km from the estuary"
        )
        y_label = "Percentage (%)"
        l_title = "Size (mm)"
    end

    for i in axes(bedload_sediment, 1)

        temp_sum = sum(view(bedload_sediment, i, :))

        bedload_sediment[i, :] .= bedload_sediment[i, :] ./ temp_sum * 100

    end

    p = StatsPlots.groupedbar(
        1965:1999,
        bedload_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(0, 100),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        # legend_font_pointsize=10,
        # legend_title_font_pointsize=10,
        # tickfontsize=12,
        # guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=:tab20
    )

    return p

end

function make_graph_particle_bedload_percentage_point_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    base_index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_particle_bedload_percentage_point_each_year(
        area_index,
        data_file,
        index_df,
        base_index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_particle_bedload_percentage_point_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    base_index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    bedload_sediment =
        particle_bedload_sediment_volume_each_year(
            area_index,
            390,
            data_file.tuple[index_df],
            each_year_timing,
            1965,
            1999,
            sediment_size
        )

    bedload_sediment_base =
        particle_bedload_sediment_volume_each_year(
            area_index,
            390,
            data_file.tuple[base_index_df],
            each_year_timing,
            1965,
            1999,
            sediment_size
        )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ",
            round(area_km, digits=2),
            " km"
        )
        y_label = "パーセントポイント (%pt)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2),
            " km from the estuary"
        )
        y_label = "Percentage point (%pt)"
        l_title = "Size (mm)"
    end

    for i in axes(bedload_sediment, 1)

        temp_sum = sum(view(bedload_sediment, i, :))

        bedload_sediment[i, :] .= bedload_sediment[i, :] ./ temp_sum * 100

    end

    for i in axes(bedload_sediment_base, 1)

        temp_sum = sum(view(bedload_sediment_base, i, :))

        bedload_sediment_base[i, :] .= bedload_sediment_base[i, :] ./ temp_sum * 100

    end

    bedload_sediment .= bedload_sediment .- bedload_sediment_base

    p = StatsPlots.groupedbar(
        1965:1999,
        bedload_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(-30, 30),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        # legend_font_pointsize=10,
        # legend_title_font_pointsize=10,
        # tickfontsize=12,
        # guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=:tab20
    )

    return p

end

function make_graph_particle_bedload_volume_each_year_with_average_line(
    area_index::Int,
    data_file::Main_df,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64,
    first_year::Int,
    final_year::Int,
    mid_year::Int;
    added_title::String="",
    japanese::Bool=false
    )


    p = make_graph_particle_bedload_volume_each_year(
        area_index,
        data_file,
        index_df,
        each_year_timing,
        sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    vec_bedload = bedload_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df], 
        each_year_timing,
        1965,
        1999
    )

    plot!(
        p,
        collect(first_year:mid_year-1),
        [mean(vec_bedload[first_year-first_year+1:(mid_year-1)-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:darksalmon,
        label=string("Average \nbefore \n", (mid_year-1))
    )

    plot!(
        p,
        collect(mid_year:final_year),
        [mean(vec_bedload[mid_year-first_year+1:final_year-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:deeppink,
        label=string("Average \nafter \n", mid_year)
    )
    
    return p

end

function make_graph_condition_change_bedload_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df_base::Int,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    string_sediment_size::Vector{String},
    river_length_km::Float64;
    added_title::String="",
    japanese::Bool=false
    )

    variation_bedload = particle_bedload_sediment_volume_each_year(
        area_index, 
        data_file.tuple[index_df],
        each_year_timing,
        1965,
        1999,
        sediment_size
    ) - particle_bedload_sediment_volume_each_year(
        area_index, 
        data_file.tuple[index_df_base],
        each_year_timing,
        1965,
        1999,
        sediment_size
    )

    area_km = abs(river_length_km - 0.2 * (area_index - 1))

    if japanese == true
        title_graph = string(
            added_title,
            "河口から ", 
            round(area_km, digits=2), 
            " km"
        )
        y_label = "掃流砂の変動量 (m³/年)"
        l_title = "粒径 (mm)"
    else
        title_graph = string(
            added_title,
            round(area_km, digits=2), 
            " km from the estuary"
        )
        y_label = "Variation in bedload (m³/year)"
        l_title = "Size (mm)"        
    end
    
    p = vline([1975], line=:black, label="", linestyle=:dot, linewidth=1)

    groupedbar!(
        p,
        collect(1965:1999), 
        variation_bedload,
        bar_position = :stack,
        legend = :outerright,
        ylims=(-5e4, 2.5e4),
        xlims=(1964, 2000),
        ylabel=y_label,
        xticks=[1965, 1975, 1985, 1995, 1999],
        label=permutedims(string_sediment_size),
        label_title=l_title,
        legend_font_pointsize=10,
        legend_title_font_pointsize=10,
        tickfontsize=12,
        guidefontsize=12,
        linecolor=:gray,
        linewidth=1,
        title = title_graph,
        palette=palette(:vik, size(sediment_size, 1)+2)
    )

end

function make_graph_condition_change_bedload_volume_each_year(
    area_index::Int,
    data_file::Main_df,
    index_df_base::Int,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64;
    added_title::String,
    japanese::Bool=false
    )

    string_sediment_size = Vector{String}(undef, size(sediment_size, 1))

    for i in 1:size(sediment_size, 1)
        if i == 1
            string_sediment_size[i] = Printf.@sprintf("%5.3f", sediment_size[i, 3])
        elseif 1 < i <= 8
            string_sediment_size[i] = Printf.@sprintf("%5.2f", sediment_size[i, 3])
        elseif 8 < i <= 11
            string_sediment_size[i] = Printf.@sprintf("%5.1f", sediment_size[i, 3])
        else
            string_sediment_size[i] = Printf.@sprintf("%5.0f", sediment_size[i, 3])
        end
    end

    p = make_graph_condition_change_bedload_volume_each_year(
        area_index,
        data_file,
        index_df_base,
        index_df,
        each_year_timing,
        sediment_size,
        string_sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )

    return p

end

function make_graph_condition_change_bedload_volume_each_year_with_average_line(
    area_index::Int,
    data_file::Main_df,
    index_df_base::Int,
    index_df::Int,
    each_year_timing::Each_year_timing,
    sediment_size::DataFrame,
    river_length_km::Float64,
    first_year::Int,
    final_year::Int,
    mid_year::Int;
    added_title::String,
    japanese::Bool=false
    )


    p = make_graph_condition_change_bedload_volume_each_year(
        area_index,
        data_file,
        index_df_base,
        index_df,
        each_year_timing,
        sediment_size,
        river_length_km;
        added_title=added_title,
        japanese=japanese
    )


    vec_bedload = bedload_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df], 
        each_year_timing,
        1965,
        1999
    ) - bedload_sediment_volume_each_year(
        area_index,
        390,
        data_file.tuple[index_df_base], 
        each_year_timing,
        1965,
        1999
    ) 

    plot!(
        p,
        collect(first_year:mid_year-1),
        [mean(vec_bedload[first_year-first_year+1:(mid_year-1)-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:darksalmon,
        label=string("Average \nbefore \n", (mid_year-1))
    )

    plot!(
        p,
        collect(mid_year:final_year),
        [mean(vec_bedload[mid_year-first_year+1:final_year-first_year+1])],
        linestyle=:dash,
        linewidth=2,
        linecolor=:deeppink,
        label=string("Average \nafter \n", mid_year)
    )

    return p

end
