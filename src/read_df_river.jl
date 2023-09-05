module Read_df_river

import CSV,
       DataFrames,
       Printf

export
    Main_df,
    get_cross_rb_df,
    get_time_schedule,
    get_observed_riverbed_level,
    get_sediment_size,
    get_fmini,
    get_river_width,
    Each_year_timing,
    Section,
    Exist_riverbed_level,
    Measured_cross_rb

#Get the maximum value of time for discharge
function get_max_num_time() 
    max_time = get_max_num_time("./")

    return max_time
end

function get_max_num_time(df_path::String) 
    condition_file = open(
        string(df_path, "Conditions.csv"),
        "r"
    )
    max_time = 0
    for i = 1:5
        max_time = parse(Int, readline(condition_file))
    end

    close(condition_file)
    return max_time
end

function get_n_years()
    n_years = get_n_years("./")
    
    return n_years
end

function get_n_years(df_path::String)
    n_years = CSV.read(
        string(df_path, "Nyear.csv"),
        DataFrames.DataFrame
    )
    
    return n_years
end

struct Each_year_timing{T<:AbstractDict{Int, Tuple{Int, Int}}}
    dict::T
end

function get_dict_each_year_timing!(
    each_year_timing::AbstractDict{Int, Tuple{Int, Int}},
    time_schedule,
    df_path::String
    )

    years = unique(time_schedule[:, :year])
      
    n_years = get_n_years(df_path)
    
    i_years    = [row[begin] for row in DataFrames.Tables.namedtupleiterator(n_years)]
    time_years = [row[end]   for row in DataFrames.Tables.namedtupleiterator(n_years)]

    max_time = get_max_num_time(df_path)
    
    for i in @view i_years[begin:end-1]
        get!(each_year_timing, years[i], (time_years[i], time_years[i+1]-1))
    end

    get!(each_year_timing, years[end], (time_years[end], max_time-1))
    
    return each_year_timing
end

function Each_year_timing(
    time_schedule,
    df_path::AbstractString="./"
    )

    each_year_timing = Dict{Int, Tuple{Int, Int}}()
    
    get_dict_each_year_timing!(
        each_year_timing,
        time_schedule,
        df_path
    )

    return Each_year_timing(each_year_timing)

end

function get_section_index!(
    section_index,
    df_path::String
    )
    mining_area_index = CSV.read(
        string(df_path, "mining_area_index.csv"),
        DataFrames.DataFrame
    )
    
    append!(
        section_index,
        Tuple.(DataFrames.Tables.namedtupleiterator(mining_area_index[!, 2:3]))
    )
    
    return section_index
end

function get_section_index()
    
    section_index = get_section_index("./")

    return section_index
end

function get_section_index(
    df_path::String
    )
    
    section_index = Vector{Tuple{Int, Int}}(undef, 0)

    get_section_index!(section_index, df_path)
    
    return section_index
end

function get_exist_riverbed_level_timing!(
    exist_riverbed_level_timing,
    exist_riverbed_level_years,
    each_year_timing::Each_year_timing
    )
    
    for i in exist_riverbed_level_years
        if haskey(each_year_timing.dict, i) == true
            push!(exist_riverbed_level_timing, each_year_timing.dict[i][1])
        end
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

function get_string_section(section_index)

    section_string = Vector{String}(undef, 0)
    get_string_section!(section_string, section_index)    
    
    return section_string
end

struct Main_df{N, T<:DataFrames.AbstractDataFrame} 

    tuple::NTuple{N, T}

end

function Main_df(df_vararg::Vararg{T, N}) where {T, N}

    return Main_df{N, T}(df_vararg)

end

function Main_df(
    file_paths::Vararg{String, N}
    ) where N

    df_vec = Vector{DataFrames.DataFrame}(undef, N)
    
    for i in 1:N
        df_vec[i] = get_main_df(file_paths[i])
    end

    return Main_df(df_vec...)

end

function get_main_df()

    df = get_main_df("./")
    
    return df
end

function get_main_df(df_path::String)
    
    df = CSV.read(
        string(df_path, "2_1DallT1.csv"),
        DataFrames.DataFrame
    )
    
    return df
end

function get_cross_rb_df()

    df = get_cross_rb_df("./")

    return df
end

function get_cross_rb_df(df_path::String)

    df = CSV.read(
        string(df_path, "3_riverbed.csv"),
        DataFrames.DataFrame
    )
    
    return df    
end

function get_time_schedule()
    time_schedule = get_time_schedule("./")
    
    return time_schedule
end

function get_time_schedule(df_path::String)
    time_schedule = CSV.read(
        string(df_path, "whole_season_time_schedule.csv"),
        DataFrames.DataFrame
    )
    
    return time_schedule
end

function get_sediment_size()
    sediment_size = get_sediment_size("./")
        
    return sediment_size
end

function get_sediment_size(df_path::String)
    sediment_size = CSV.read(
        string(df_path, "Sed_size.csv"),
        DataFrames.DataFrame
    )
    sediment_size.diameter_mm = sediment_size[!, 2] * 1000
    
    return sediment_size
end

function get_fmini()
    fmini = get_fmini("./")
    
    return fmini
end

function get_fmini(df_path::String)
    fmini = CSV.read(
        string(df_path, "Fmini.csv"),
        DataFrames.DataFrame
    )
    
    return fmini
end

function get_river_width()
    river_width = get_river_width("./")

    return river_width
end

function get_river_width(df_path::String)
    river_width = CSV.read(
        string(df_path, "river_width.csv"),
        DataFrames.DataFrame
    )

    return river_width
end

function get_observed_riverbed_level()
    observed_riverbed_level = get_observed_riverbed_level("./")
    
    return observed_riverbed_level
end

function get_observed_riverbed_level(df_path::String)
    observed_riverbed_level = CSV.read(
        string(df_path, "observed_riverbed_level.csv"),
        DataFrames.DataFrame
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

    return Section("./")
end

function Section(df_path::String)
    section_index = get_section_index(df_path)

    section_string= get_string_section(section_index)
    
    return Section(section_index, section_string)
end

struct Exist_riverbed_level{T<:AbstractVector{Int}}
    years::T
    timing::T
end

function Exist_riverbed_level(
    observed_riverbed_level,
    each_year_timing::Each_year_timing
    )
    exist_riverbed_level_years=get_exist_riverbed_level_years(observed_riverbed_level)

    exist_riverbed_level_timing = Vector{Int}(undef, 0)
    get_exist_riverbed_level_timing!(
        exist_riverbed_level_timing, exist_riverbed_level_years,
        each_year_timing
    )
    
    return Exist_riverbed_level(exist_riverbed_level_years, exist_riverbed_level_timing)
end

struct Measured_cross_rb{T<:DataFrames.AbstractDataFrame}

    dict::Dict{Int, T}

end

function Measured_cross_rb(
    exist_riverbed_level::Exist_riverbed_level,
    df_path::String
    )

    measured_cross_rb = Dict{Int, DataFrames.DataFrame}()

    for year in exist_riverbed_level.years
        get!(
            measured_cross_rb,
            year,
            CSV.read(
                string(
                    df_path,
                    year,
                    "_measured_cross_rb.csv"),
                DataFrames.DataFrame
            )
        )
    end

    return Measured_cross_rb(measured_cross_rb)

end

#mining_volume = CSV.read("./mining_volume.csv", DataFrames.DataFrame)

end
