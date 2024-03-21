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

module RMSE

using Plots: legendtitlefont
using Printf, Plots, CSV
using Statistics, DataFrames
using ..GeneralGraphModule
using ..FigureGeneration

export
    calculate_RMSE,
    calculate_each_year_RMSE,
    make_RMSE_fluctuation_graph_each,
    make_RMSE_csv

function error_actual_mean_riverbed(data_file, initial_and_final_riverbed_level, target_hour, which_type)
    differential_riverbed = initial_and_final_riverbed_level[!, Symbol(which_type)]
    .- mean(initial_and_final_riverbed_level[!, which_type])
    return differential_riverbed
end

function error_simulated_and_actual_riverbed(
    data_file::DataFrames.AbstractDataFrame,
    initial_and_final_riverbed_level::DataFrames.AbstractDataFrame,
    target_hour::Int,
    year_symbol::Symbol,
    riverbed_symbol::Symbol
    )
    first_i, last_i = decide_index_number(target_hour)
    differential_riverbed =
        initial_and_final_riverbed_level[!, year_symbol] .-
        data_file[first_i:last_i, riverbed_symbol]
    return differential_riverbed
end

function calculate_RMSE(
    error_vector::AbstractVector
)
    rmse = sqrt(
        mean(
            error_vector .^ 2
        )
    )
    return rmse
end


function calculate_RMSE(
    data_file::DataFrames.AbstractDataFrame,
    initial_and_final_riverbed_level::DataFrames.AbstractDataFrame,
    target_hour::Int,
    year_symbol::Symbol,
    riverbed_symbol::Symbol
)

    rmse = calculate_RMSE(
        error_simulated_and_actual_riverbed(
            data_file,
            initial_and_final_riverbed_level,
            target_hour,
            year_symbol,
            riverbed_symbol
        )
    )

    return rmse
end

#Version by section
function calculate_RMSE(
    data_file::DataFrames.AbstractDataFrame,
    initial_and_final_riverbed_level::DataFrames.AbstractDataFrame,
    target_hour::Int,
    year_symbol::Symbol,
    riverbed_symbol::Symbol,
    index_first::Int,
    index_end::Int
    )

    rmse = calculate_RMSE(
        view(
            error_simulated_and_actual_riverbed(
                data_file,
                initial_and_final_riverbed_level,
                target_hour,
                year_symbol,
                riverbed_symbol
            ),
            index_first:index_end
        )
    )

    return rmse
end

#全区間
function calculate_each_year_RMSE(
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    riverbed_symbol::Symbol
    )

    list_RMSE=zeros(
        Union{Float64, Missing},
        length(exist_riverbed_level.years)
    )
    calculate_each_year_RMSE!(
        list_RMSE,
        exist_riverbed_level,
        each_year_timing,
        data_file,
        initial_and_final_riverbed_level,
        riverbed_symbol
    )

    return list_RMSE
end

function calculate_each_year_RMSE!(
    list_RMSE::AbstractVector{<:Union{Float64, Missing}},
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    riverbed_symbol::Symbol
    )

    for i in eachindex(exist_riverbed_level.years)
        target_year = exist_riverbed_level.years[i]
        if haskey(each_year_timing.dict, target_year) == true
            list_RMSE[i] =
                calculate_RMSE(
                    data_file,
                    initial_and_final_riverbed_level,
                    each_year_timing.dict[target_year][2],
                    Symbol(target_year),
                    riverbed_symbol
                )
        else
            list_RMSE[i] = missing
        end
    end

    return nothing

end

#区間別
function calculate_each_year_RMSE(
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    riverbed_symbol::Symbol,
    section::FigureGeneration.Section,
    index_section::Int
    )

    list_RMSE=zeros(
        Union{Float64, Missing},
        length(exist_riverbed_level.years)
    )
    calculate_each_year_RMSE!(
        list_RMSE,
        exist_riverbed_level,
        each_year_timing,
        data_file,
        initial_and_final_riverbed_level,
        riverbed_symbol,
        section,
        index_section
    )

    return list_RMSE
end

function calculate_each_year_RMSE!(
    list_RMSE::AbstractVector{<:Union{Float64, Missing}},
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    riverbed_symbol::Symbol,
    section::FigureGeneration.Section,
    index_section::Int
    )

    for i in eachindex(exist_riverbed_level.years)
        target_year = exist_riverbed_level.years[i]
        if haskey(each_year_timing.dict, target_year) == true
            list_RMSE[i] =
                calculate_RMSE(
                    data_file,
                    initial_and_final_riverbed_level,
                    each_year_timing.dict[target_year][2],
                    Symbol(target_year),
                    riverbed_symbol,
                    section.index[index_section][1],
                    section.index[index_section][2]
                )
        else
            list_RMSE[i] = missing
        end
    end

    return nothing

end


function make_RMSE_fluctuation_graph_each(
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    section::FigureGeneration.Section,
    riverbed_symbol::Symbol;
    japanese::Bool=false
)

    if japanese==true
        legend_t = "河口からの距離"
        label_x  = "年"
    else
        legend_t = "Distance from the estuary"
        label_x  = "Year"
    end

    p=plot(
        legend_title=legend_t,
        ylabel="RMSE (m)",
        xlabel=label_x,
        legend_title_font_pointsize=10,
        legend_font_pointsize=9
    )

    markershapes = [:diamond, :circle, :utriangle, :pentagon, :dtriangle]

    list_RMSE=zeros(
        Union{Float64, Missing},
        length(exist_riverbed_level.years)
    )

    #4つの区間に分けた場合
    for section_number in eachindex(section.index)

        list_RMSE .= 0.0

        calculate_each_year_RMSE!(
            list_RMSE,
            exist_riverbed_level,
            each_year_timing,
            data_file,
            initial_and_final_riverbed_level,
            riverbed_symbol,
            section,
            section_number
        )

        plot!(
            p,
            exist_riverbed_level.years,
            list_RMSE,
            label=section.string[section_number],
            xlims=(1964, 2001),
            ylims=(0.0, 1.25),
            legend=:bottomright,
            linewidth=4,
            markershape=markershapes[section_number],
            markersize=8,
            dpi=300,
            palette=:Set1_5
        )


    end

    list_RMSE .= 0.0

    calculate_each_year_RMSE!(
        list_RMSE,
        exist_riverbed_level,
        each_year_timing,
        data_file,
        initial_and_final_riverbed_level,
        riverbed_symbol
    )

    plot!(
        p,
        exist_riverbed_level.years,
        list_RMSE,
        label="0.0-77.8 km",
        linewidth=4,
        markershape=markershapes[end],
        markersize=8
    )

    return p

end

function make_RMSE_df(
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    section::FigureGeneration.Section,
    riverbed_symbol::Symbol
)

    df_rmse = DataFrame()

    make_RMSE_df!(
        df_rmse,
        exist_riverbed_level,
        each_year_timing,
        data_file,
        initial_and_final_riverbed_level,
        section,
        riverbed_symbol
    )

    return df_rmse

end


function make_RMSE_df!(
    df_rmse::DataFrames.AbstractDataFrame,
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    section::FigureGeneration.Section,
    riverbed_symbol::Symbol
    )

    df_rmse.year = exist_riverbed_level.years

    list_RMSE=zeros(
        Union{Float64, Missing},
        length(exist_riverbed_level.years)
    )

    #全区間
    calculate_each_year_RMSE!(
        list_RMSE,
        exist_riverbed_level,
        each_year_timing,
        data_file,
        initial_and_final_riverbed_level,
        riverbed_symbol
    )

    df_rmse.whole = list_RMSE

    #区間に分けた場合
    for section_number in eachindex(section.index)
        list_RMSE .= 0

        calculate_each_year_RMSE!(
	    list_RMSE,
            exist_riverbed_level,
            each_year_timing,
	    data_file,
            initial_and_final_riverbed_level,
            riverbed_symbol,
            section,
            section_number
	    )

        df_rmse[!, section.string[section_number]] .= list_RMSE

    end

    return nothing

end

function make_RMSE_csv(
    file_path::AbstractString,
    exist_riverbed_level::FigureGeneration.Exist_riverbed_level,
    each_year_timing::FigureGeneration.Each_year_timing,
    data_file,
    initial_and_final_riverbed_level,
    section::FigureGeneration.Section,
    riverbed_symbol::Symbol
    )

    df_rmse = make_RMSE_df(
        exist_riverbed_level,
        each_year_timing,
        data_file,
        initial_and_final_riverbed_level,
        section,
        riverbed_symbol
    )

    CSV.write(
        file_path,
        df_rmse,
        missingstring="missing"
    )

    return nothing

end

end
