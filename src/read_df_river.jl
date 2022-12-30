module Read_df_river

import CSV,
       DataFrames,
       Printf

export get_main_df,
       get_time_schedule,
       get_dict_each_year_timing!,
       get_observed_riverbed_level,
       get_sediment_size,
       get_fmini,
       Section,
       Exist_riverbed_level

#Get the maximum value of time for discharge
function get_max_num_time() 
    condition_file = open("./Conditions.csv", "r")
    max_time = 0
    for i = 1:5
        max_time = parse(Int, readline(condition_file))
    end
    return max_time
end

function get_n_years()
    n_years = CSV.read(
        "./Nyear.csv", DataFrames.DataFrame
    )
    
    return n_years
end

function get_dict_each_year_timing!(
        each_year_timing, time_schedule
    )

    years = unique(time_schedule[:, :year])
      
    n_years = get_n_years()
    
    i_years    = [row[begin] for row in DataFrames.Tables.namedtupleiterator(n_years)]
    time_years = [row[end]   for row in DataFrames.Tables.namedtupleiterator(n_years)]
    
    max_time = get_max_num_time()
    
    for i in @view i_years[begin:end-1]
        get!(each_year_timing, years[i], (time_years[i], time_years[i+1]-1))
    end

    get!(each_year_timing, years[end], (time_years[end], max_time-1))
    
    return each_year_timing
end

function get_dict_each_year_timing(time_schedule)

    each_year_timing = Dict{Int, Tuple{Int, Int}}()
    
    get_dict_each_year_timing!(
        each_year_timing, time_schedule
    )
    return each_year_timing
end

function get_section_index!(section_index)
    mining_area_index = CSV.read(
        "./mining_area_index.csv", DataFrames.DataFrame
        )

    append!(section_index, Tuple.(DataFrames.Tables.namedtupleiterator(mining_area_index[!, 2:3])))
    
    return section_index
end

function get_section_index()
    
    section_index = Vector{Tuple{Int, Int}}(undef, 0)

    get_section_index!(section_index)
    
    return section_index
end

function get_exist_riverbed_level_timing!(
        exist_riverbed_level_timing, exist_riverbed_level_years,
        each_year_timing
    )
    
    for i in exist_riverbed_level_years
        push!(exist_riverbed_level_timing, each_year_timing[i][1])
    end
        
    return exist_riverbed_level_timing
end

function get_string_section!(section_string, section_index)
    
    for i in 1:length(section_index)
        push!(
            section_string,
            Printf.@sprintf(
                "%.1f-%.1f km",
                ((section_index[1][2]-1) - (section_index[i][2]-1))*0.2,
                ((section_index[1][2]-1) - (section_index[i][1]-1))*0.2
            )
        )
    end
    
    return section_string
end

function get_main_df()
    
    df = CSV.read("./2_1DallT1.csv", DataFrames.DataFrame)
    
    return df
end

function get_time_schedule()
    time_schedule = CSV.read(
        "./whole_season_time_schedule.csv", DataFrames.DataFrame
    )
    
    return time_schedule
end

function get_sediment_size()
    sediment_size = CSV.read("./Sed_size.csv", DataFrames.DataFrame)
    sediment_size.diameter_mm = sediment_size[!, 2] * 1000
    
    return get_sediment_size
end

function get_fmini()
    fmini = CSV.read("./Fmini.csv", DataFrames.DataFrame)
    
    return fmini
end

function get_observed_riverbed_level()
    observed_riverbed_level = CSV.read(
        "./1965-1999_observed_riverbed_level.csv", DataFrames.DataFrame
    )
    
    return observed_riverbed_level
end

function get_exist_riverbed_level_years(observed_riverbed_level)
    exist_riverbed_level_years=parse.(Int, @view names(observed_riverbed_level)[begin+1:end])
    
    return exist_riverbed_level_years
end

struct Section
    index::Vector{Tuple{Int, Int}}
    string::Vector{String}
end

function Section()
    section_index = Vector{Tuple{Int, Int}}(undef, 0)
    get_section_index!(section_index)

    section_string = Vector{String}(undef, 0)
    get_string_section!(section_string, section_index)
        
    return Section(section_index, section_string)
end

struct Exist_riverbed_level
    years::Vector{Int}
    timing::Vector{Int}
end

function Exist_riverbed_level(observed_riverbed_level, each_year_timing)
    exist_riverbed_level_years=get_exist_riverbed_level_years(observed_riverbed_level)

    exist_riverbed_level_timing = Vector{Int}(undef, 0)
    get_exist_riverbed_level_timing!(
        exist_riverbed_level_timing, exist_riverbed_level_years,
        each_year_timing
    )
        
    return Exist_riverbed_level(exist_riverbed_level_years, exist_riverbed_level_timing)
end

#df_cross = CSV.read("./3_riverbed.csv", DataFrame)

#mining_volume = CSV.read("./mining_volume.csv", DataFrames.DataFrame)

end