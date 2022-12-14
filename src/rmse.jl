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

using Printf, Plots, CSV
using Statistics, DataFrames
using ..GeneralGraphModule

export
    calculate_RMSE,
    calculate_each_year_RMSE,
    make_RMSE_fluctuation_graph_each_ja,
    make_RMSE_csv

function error_actual_mean_riverbed(data_file, initial_and_final_riverbed_level, target_hour, which_type)
    seconds_now = 3600 * target_hour
    differential_riverbed = initial_and_final_riverbed_level[!, which_type]
    .- mean(initial_and_final_riverbed_level[!, which_type])
    return differential_riverbed
end

function error_simulated_and_actual_riverbed(data_file, initial_and_final_riverbed_level, target_hour, which_type)
    seconds_now = 3600 * target_hour
    differential_riverbed =
    initial_and_final_riverbed_level[!, which_type] .- data_file[data_file.T .== seconds_now, :Zbave]
    return differential_riverbed
end

function calculate_RMSE(data_file, initial_and_final_riverbed_level, target_hour, which_type)
    rmse=sqrt(mean(
    error_simulated_and_actual_riverbed(data_file, initial_and_final_riverbed_level, target_hour, which_type).^2
    ))
    return rmse
end

#Version by section
function calculate_RMSE(data_file, initial_and_final_riverbed_level, target_hour, which_type, index_first, index_end)
    rmse=sqrt(mean(
    error_simulated_and_actual_riverbed(
    data_file, initial_and_final_riverbed_level, target_hour, which_type
    )[index_first:index_end].^2))
    return rmse
end

#?????????
function calculate_each_year_RMSE(
    exist_riverbed_level_years,each_year_timing,data_file,
    initial_and_final_riverbed_level
    )

    list_RMSE=zeros(Float64, length(exist_riverbed_level_years))
    calculate_each_year_RMSE!(
        list_RMSE,exist_riverbed_level_years,each_year_timing,
        data_file,initial_and_final_riverbed_level
        )
    
    return list_RMSE
end

function calculate_each_year_RMSE!(
list_RMSE,exist_riverbed_level_years,each_year_timing,data_file,initial_and_final_riverbed_level)
    
    for (i, target_year) in enumerate(exist_riverbed_level_years)
        list_RMSE[i] =
	calculate_RMSE(
	data_file,initial_and_final_riverbed_level,
	each_year_timing[target_year][2],string(target_year))
    end
    
    return list_RMSE
    
end

#?????????
function calculate_each_year_RMSE(
    exist_riverbed_level_years,each_year_timing,data_file,
    initial_and_final_riverbed_level,section_index,which_section
    )

    list_RMSE_section=zeros(Float64, length(exist_riverbed_level_years))
    calculate_each_year_RMSE!(
        list_RMSE_section,exist_riverbed_level_years,each_year_timing,
        data_file,initial_and_final_riverbed_level,
        section_index,which_section
        )
    
    return list_RMSE_section
end

function calculate_each_year_RMSE!(
list_RMSE,exist_riverbed_level_years,each_year_timing,data_file,
initial_and_final_riverbed_level,section_index,which_section::Int)
    
    for (i, year) in enumerate(exist_riverbed_level_years)
        string_year = string(year)
        list_RMSE[i]=
	calculate_RMSE(data_file,initial_and_final_riverbed_level,
	each_year_timing[year][2],string_year,
        section_index[which_section][1],section_index[which_section][2])
    end
    
    return list_RMSE
end

function make_RMSE_fluctuation_graph_each_ja(
exist_riverbed_level_years,each_year_timing,data_file,initial_and_final_riverbed_level,
section_index,label_list
)
    
    year_list=[x for x in exist_riverbed_level_years]
    
    p=plot(legend_title="?????????????????????")
    
    markershapes=[:diamond,:circle,:utriangle,:pentagon,:dtriangle]
    
    #4??????????????????????????????
    for section_number in 1:length(section_index)
        list_RMSE_section=zeros(Float64, length(exist_riverbed_level_years))
        calculate_each_year_RMSE!(
	    list_RMSE_section,exist_riverbed_level_years,each_year_timing,
	    data_file,initial_and_final_riverbed_level,
            section_index,section_number
	    )
        
        plot!(p,year_list,list_RMSE_section,
	    label=label_list[section_number],
	    xlims=(1964,2001),ylims=(0,1.0),
            legend=:bottomright, linewidth=4,
	    markershape=markershapes[section_number],
	    markersize=8,dpi=300,palette=:Set1_5,
            xlabel="???", ylabel="RMSE (m)")
        
    end
    
    list_RMSE=zeros(Float64, length(exist_riverbed_level_years))
        
    calculate_each_year_RMSE!(list_RMSE,exist_riverbed_level_years,
        each_year_timing,data_file,initial_and_final_riverbed_level)
    
    plot!(p, year_list, list_RMSE, label="0.0-77.8 km", linewidth=4,
        markershape=markershapes[end], markersize=8)
    
    return p
    
end

function make_RMSE_df!(df_rmse::DataFrame,
    exist_riverbed_level_years,each_year_timing,data_file,initial_and_final_riverbed_level,
    section_index,string_section
    )

    year_list=collect(exist_riverbed_level_years)

    df_rmse[!, :year]  = year_list

    #?????????
    list_RMSE=zeros(Float64, length(exist_riverbed_level_years))
    calculate_each_year_RMSE!(list_RMSE,exist_riverbed_level_years,
        each_year_timing,data_file,initial_and_final_riverbed_level)

    df_rmse[!, :whole] = list_RMSE

    #????????????????????????
    for section_number in 1:length(section_index)
        list_RMSE=zeros(Float64, length(exist_riverbed_level_years))
        calculate_each_year_RMSE!(
	    list_RMSE,exist_riverbed_level_years,each_year_timing,
	    data_file,initial_and_final_riverbed_level,
            section_index,section_number
	    )
        
        df_rmse[!, string_section[section_number]] = list_RMSE
        
    end
        
    return df_rmse
    
end

function make_RMSE_df(
exist_riverbed_level_years,each_year_timing,data_file,initial_and_final_riverbed_level,
section_index,string_section
)

    df_rmse = DataFrame()

    make_RMSE_df!(df_rmse,
        exist_riverbed_level_years,each_year_timing,data_file,initial_and_final_riverbed_level,
        section_index,string_section
        )

    return df_rmse
    
end

function make_RMSE_csv(
    exist_riverbed_level_years,each_year_timing,data_file,initial_and_final_riverbed_level,
    section_index,string_section
    )

    df_rmse = make_RMSE_df(
                  exist_riverbed_level_years,each_year_timing,data_file,
		  initial_and_final_riverbed_level,
                  section_index,string_section
                  )

    CSV.write(
        "./csv_data/rmse.csv",df_rmse
        )
end

end
