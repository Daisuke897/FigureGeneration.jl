function heatmap_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    year::Int;
    japanese::Bool=false
    )
    
    X = 0:0.2:((size(measured_cross_rb.dict[year], 2)-1) * 0.2)
    
    Y = collect(Float64, 0:size(measured_cross_rb.dict[year], 1)-1) ./ (size(measured_cross_rb.dict[year], 1)-1)
    
    if japanese == true 
        cl_t = "河床位 (T. P. m)"
        xl   = "河口からの距離 (km)"
        yl   = "川幅 (-)"
    else
        cl_t = "Riverbed elevation (T. P. m)"
        xl   = "Distance from the estuary (km)"
        yl   = "Width (-)"
    end
    
    p = heatmap(
        X,
        Y, 
        reverse(Matrix(measured_cross_rb.dict[year])), 
        color=:heat,
        colorbar_title=cl_t,
        colorbar_titlefontsize=13,
        colorbar_tickfontsize=11,
        clims=(-10, 90),  
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=xl,
        xflip=true,
        ylabel=yl,
        title=year  
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dash, linewidth=1)
    
    return p
    
end

function heatmap_error_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    year::Int,
    cross_rb::DataFrame,
    time_schedule::DataFrame,
    target_hour::Int,
    string_title::String;
    japanese::Bool=false
    )
    
    X = 0:0.2:((size(measured_cross_rb.dict[year], 2)-1) * 0.2)
    
    Y = collect(Float64, 0:size(measured_cross_rb.dict[year], 1)-1) ./ (size(measured_cross_rb.dict[year], 1)-1)
    
    if japanese == true 
        cl_t = "誤差 (m)"
        xl   = "河口からの距離 (km)"
        yl   = "川幅 (-)"
    else
        cl_t = "Error (m)"
        xl   = "Distance from the estuary (km)"
        yl   = "Width (-)"
    end
    
    measured_rb = Matrix(measured_cross_rb.dict[year])
    
    (first_index, final_index) = decide_index_number(
        target_hour,
        size(measured_cross_rb.dict[year], 2)
    )
    
    simulated_rb = Matrix(
        cross_rb[first_index:final_index, Between(:Zb001, :Zb101)]
    )'
    
    error_rb = simulated_rb - measured_rb

    want_title = making_time_series_title(string_title, target_hour, time_schedule)
    
    p = heatmap(
        X,
        Y,
        reverse!(error_rb),
        color=:seismic,
        colorbar=:bottom,
        colorbar_title=cl_t,
        colorbar_titlefontsize=13,
        colorbar_tickfontsize=11,
        clims=(-14, 14),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=xl,
        xflip=true,
        ylabel=yl,
        title=want_title
    )
    
    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )
    
    return p
    
end

function heatmap_slope_by_model_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int;
    japanese::Bool=false
    )

        slope_cross_rb_ele = zeros(size(measured_cross_rb.dict[start_year]))
        
        slope_linear_model_measured_cross_rb_elevation!(
            slope_cross_rb_ele,
            measured_cross_rb,
            start_year,
            final_year
        )
    
        X = 0:0.2:((size(measured_cross_rb.dict[start_year], 2)-1) * 0.2)
    
        Y = collect(Float64, 0:(size(measured_cross_rb.dict[start_year], 1)-1)) ./ (size(measured_cross_rb.dict[start_year], 1)-1)
        
        if japanese == true 
            cl_t = "線形回帰式の傾き (m/年)"
            xl   = "河口からの距離 (km)"
            yl   = "川幅 (-)"
        else
            cl_t = "Slope of linear regression (m/year)"
            xl   = "Distance from the estuary (km)"
            yl   = "Width (-)"
        end
        
        figure_title = string(start_year, " - ", final_year)

        p = heatmap(
            X,
            Y, 
            reverse!(slope_cross_rb_ele), 
            color=:seismic,
            colorbar_title=cl_t,
            colorbar_titlefontsize=13,
            colorbar_tickfontsize=11,
            clims=(-1.0, 1.0),
            xticks=[0, 20, 40, 60, 77.8],
            xlabel=xl,
            ylabel=yl,
            title=figure_title,
            xflip=true
        )
    
        vline!(
            p,
            [40.2,24.4,14.6],
            line=:black,
            label="",
            linestyle=:dash,
            linewidth=1
        )
    
        return p
    
end

function slope_linear_model_simulated_cross_rb_elevation!(
        slope_linear_cross_rb::Matrix{Float64},
        cross_rb::DataFrame,
        each_year_timing::Each_year_timing,
        n_x::Int64,
        n_y::Int64,
        start_year::Int64,
        final_year::Int64
    )
    
    for area_index_cross in 1:n_y
       
        for area_index_flow in 1:n_x
            
            slope_linear_cross_rb[area_index_flow, area_index_cross] = GLM.coef(
                RiverbedGraph.fit_linear_variation_per_year_simulated_riverbed_level(
                    cross_rb,
                    each_year_timing,
                    area_index_flow,
                    area_index_cross,
                    n_x,
                    start_year,
                    final_year
                )
            )[2]
            
        end
        
    end
    
    return slope_linear_cross_rb
    
end

function slope_linear_model_simulated_cross_rb_elevation(
        cross_rb::DataFrame,
        each_year_timing::Each_year_timing,
        n_x::Int64,
        n_y::Int64,
        start_year::Int64,
        final_year::Int64
    )
    
    slope_linear_cross_rb = zeros(Float64, n_x, n_y)
    
    slope_linear_model_simulated_cross_rb_elevation!(
        slope_linear_cross_rb,
        cross_rb,
        each_year_timing,
        n_x,
        n_y,
        start_year,
        final_year
    )
    
    return slope_linear_cross_rb
    
end

function heatmap_slope_by_model_simulated_cross_rb_elevation(
        cross_rb::DataFrame,
        each_year_timing::Each_year_timing,
        n_x::Int64,
        n_y::Int64,
        start_year::Int64,
        final_year::Int64;
        japanese::Bool = false
    )
    
    slope_linear_cross_rb = zeros(Float64, n_x, n_y)
    
    slope_linear_model_simulated_cross_rb_elevation!(
        slope_linear_cross_rb,
        cross_rb,
        each_year_timing,
        n_x,
        n_y,
        start_year,
        final_year
    )
    
    X = 0:0.2:((n_x - 1) * 0.2)
    Y = collect(Float64, 0:(n_y-1)) ./ (n_y-1)
    
    if japanese == true 
        cl_t = "線形回帰式の傾き (m/年)"
        xl   = "河口からの距離 (km)"
        yl   = "川幅 (-)"
    else
        cl_t = "Slope of linear regression (m/year)"
        xl   = "Distance from the estuary (km)"
        yl   = "Width (-)"
    end
    
    figure_title = string(start_year, " - ", final_year)
    
    reverse!(slope_linear_cross_rb)
    
    p = heatmap(
        X,
        Y, 
        slope_linear_cross_rb', 
        color=:seismic,
        colorbar_title=cl_t,
        colorbar_titlefontsize=13,
        colorbar_tickfontsize=11,
        clims=(-1.0, 1.0),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=xl,
        ylabel=yl,
        title=figure_title,
        xflip=true
    )
    
    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )

    return p
    
end

function heatmap_diff_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int;
    japanese::Bool=false
    )
    
    if haskey(measured_cross_rb.dict, start_year) && haskey(measured_cross_rb.dict, final_year)
        diff_cross_rb_ele = zeros(size(measured_cross_rb.dict[start_year]))
        
        diff_measured_cross_rb_elevation!(
            diff_cross_rb_ele,
            measured_cross_rb,
            start_year,
            final_year
        )
        
    
        X = 0:0.2:((size(measured_cross_rb.dict[start_year], 2)-1) * 0.2)
    
        Y = collect(Float64, 0:(size(measured_cross_rb.dict[start_year], 1) - 1)) ./ (size(measured_cross_rb.dict[start_year], 1) - 1)
        
        if japanese == true 
            cl_t = "変化 (m)"
            xl   = "河口からの距離 (km)"
            yl   = "川幅 (-)"
        else
            cl_t = "Variation (m)"
            xl   = "Distance from the estuary (km)"
            yl   = "Width (-)"
        end
        
        figure_title = string(start_year, " - ", final_year)

        p = heatmap(
            X,
            Y, 
            reverse!(diff_cross_rb_ele), 
            color=:seismic,
            colorbar_title=cl_t,
            colorbar_titlefontsize=13,
            colorbar_tickfontsize=11,
            clims=(-15, 15),
            xticks=[0, 20, 40, 60, 77.8],
            xlabel=xl,
            ylabel=yl,
            title=figure_title
        )
    
        vline!(
            p,
            [40.2,24.4,14.6],
            line=:black,
            label="",
            linestyle=:dash,
            linewidth=1
        )
    
        return p
        
    else
        
        error("There is no actual measured river bed elevation for that year.")
        
    end
    
end

function heatmap_diff_per_year_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int;
    japanese::Bool=false
    )
    
    if haskey(measured_cross_rb.dict, start_year) && haskey(measured_cross_rb.dict, final_year)
        diff_cross_rb_ele = zeros(size(measured_cross_rb.dict[start_year]))
        
        diff_measured_cross_rb_elevation!(
            diff_cross_rb_ele,
            measured_cross_rb,
            start_year,
            final_year
        )
        
        diff_cross_rb_ele ./= (final_year - start_year + 1)
    
        X = 0:0.2:((size(measured_cross_rb.dict[start_year], 2)-1) * 0.2)
    
        Y = collect(Float64, 0:(size(measured_cross_rb.dict[start_year], 1) - 1)) ./ (size(measured_cross_rb.dict[start_year], 1) - 1)
        
        if japanese == true 
            cl_t = "変化 (m/年)"
            xl   = "河口からの距離 (km)"
            yl   = "川幅 (-)"
        else
            cl_t = "Variation (m/year)"
            xl   = "Distance from the estuary (km)"
            yl   = "Width (-)"
        end
        
        figure_title = string(start_year, " - ", final_year)

        p = heatmap(
            X,
            Y, 
            reverse!(diff_cross_rb_ele), 
            color=:seismic,
            colorbar_title=cl_t,
            colorbar_titlefontsize=13,
            colorbar_tickfontsize=11,
            clims=(-2, 2),
            xticks=[0, 20, 40, 60, 77.8],
            xlabel=xl,
            ylabel=yl,
            title=figure_title,
            xflip=true
        )
    
        vline!(
            p,
            [40.2,24.4,14.6],
            line=:black,
            label="",
            linestyle=:dash,
            linewidth=1
        )
    
        return p
        
    else
        
        error("There is no actual measured river bed elevation for that year.")
        
    end
    
end

# この関数の結果が正しいのか詳細に見る必要がある。
function heatmap_diff_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    start_year::Int,
    final_year::Int;
    japanese::Bool=false
    )
    
    if haskey(measured_cross_rb.dict, start_year) && haskey(measured_cross_rb.dict, final_year)
        diff_cross_rb_ele = zeros(size(measured_cross_rb.dict[start_year]))
        
        diff_measured_cross_rb_elevation!(
            diff_cross_rb_ele,
            measured_cross_rb,
            start_year,
            final_year
        )
        
        X = 0:0.2:((size(measured_cross_rb.dict[start_year], 2)-1) * 0.2)
    
        Y = collect(Float64, 0:(size(measured_cross_rb.dict[start_year], 1) - 1)) ./ (size(measured_cross_rb.dict[start_year], 1) - 1)
        
        if japanese == true 
            cl_t = "変化 (m)"
            xl   = "河口からの距離 (km)"
            yl   = "川幅 (-)"
        else
            cl_t = "Variation (m)"
            xl   = "Distance from the estuary (km)"
            yl   = "Width (-)"
        end
        
        figure_title = string(start_year, " - ", final_year)

        p = heatmap(
            X,
            Y, 
            reverse!(diff_cross_rb_ele), 
            color=:seismic,
            colorbar_title=cl_t,
            colorbar_titlefontsize=13,
            colorbar_tickfontsize=11,
            clims=(-2, 2),
            xticks=[0, 20, 40, 60, 77.8],
            xlabel=xl,
            ylabel=yl,
            title=figure_title,
            xflip=true
        )
    
        vline!(
            p,
            [40.2,24.4,14.6],
            line=:black,
            label="",
            linestyle=:dash,
            linewidth=1
        )
    
        return p
        
    else
        
        error("There is no actual measured river bed elevation for that year.")
        
    end
    
end


function heatmap_diff_per_year_simulated_cross_rb_elevation(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    n_x::Int64,
    n_y::Int64,
    start_year::Int64,
    final_year::Int64;
    japanese::Bool = false
    )
    

    diff_cross_rb_ele = zeros(Float64, n_x, n_y)

    i_start_1 = GeneralGraphModule.decide_index_number(
        each_year_timing.dict[start_year][1],
        n_x
    )[1]

    i_start_2 = GeneralGraphModule.decide_index_number(
        each_year_timing.dict[final_year][2],
        n_x
    )[1]

    for i in 1:n_y

        for j in 1:n_x

            diff_cross_rb_ele[j, i] = cross_rb[i_start_2+j-1, Symbol(Printf.@sprintf("Zb%03i", i))] -
                cross_rb[i_start_1+j-1, Symbol(Printf.@sprintf("Zb%03i", i))]

        end

    end
    
    diff_cross_rb_ele ./= (final_year - start_year + 1)

    X = 0:0.2:((n_x - 1) * 0.2)
    Y = collect(Float64, 0:(n_y-1)) ./ (n_y-1)

    if japanese == true 
        cl_t = "変化 (m/年)"
        xl   = "河口からの距離 (km)"
        yl   = "川幅 (-)"
    else
        cl_t = "Variation (m/year)"
        xl   = "Distance from the estuary (km)"
        yl   = "Width (-)"
    end
    
    figure_title = string(start_year, " - ", final_year)

    reverse!(diff_cross_rb_ele)    

    p = heatmap(
        X,
        Y, 
        diff_cross_rb_ele', 
        color=:seismic,
        colorbar_title=cl_t,
        colorbar_titlefontsize=13,
        colorbar_tickfontsize=11,
        clims=(-1.0, 1.0),
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=xl,
        ylabel=yl,
        title=figure_title,
        xflip=true
    )
    
    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dash,
        linewidth=1
    )
    
    return p
    
end

function heatmap_std_measured_cross_rb_elevation(
    measured_cross_rb::Measured_cross_rb,
    first_year::Int,
    final_year::Int;
    japanese::Bool=false
    )

    years = Vector{Int}(undef, 0)
    
    for year in sort(collect(keys(measured_cross_rb.dict)))
        if first_year <= year && year <= final_year
            push!(years, year)
        end
    end

    if length(years) > 0
        std_cross_rb_ele = zeros(size(measured_cross_rb.dict[years[1]]))
    else
        error()
    end
    
    calc_std_cross_rb_elevation!(
        std_cross_rb_ele,
        measured_cross_rb,
        years
    )
    
    X = 0:0.2:((size(std_cross_rb_ele, 2)-1) * 0.2)
    Y = collect(Float64, 0:(size(std_cross_rb_ele, 1) - 1)) ./ (size(std_cross_rb_ele, 1) - 1)
    
    if japanese == true 
        cl_t = "標準偏差 (m)"
        xl   = "河口からの距離 (km)"
        yl   = "川幅 (-)"
    else
        cl_t = "Standard deviation (m)"
        xl   = "Distance from the estuary (km)"
        yl   = "Width (-)"
    end

    figure_title = string(first_year, " - ", final_year)
    
    p = heatmap(
        X,
        Y, 
        reverse!(std_cross_rb_ele), 
        color=:amp,
        colorbar_title=cl_t,
        colorbar_titlefontsize=14,
        colorbar_tickfontsize=11,
        xticks=[0, 20, 40, 60, 77.8],
        xlabel=xl,
        ylabel=yl,
        clims=(0, 4.2),
        xflip=true,
        title=figure_title
    )
    
    vline!(
        p,
        [40.2,24.4,14.6],
        line=:black,
        label="",
        linestyle=:dot,
        linewidth=1
    )
    
    return p
    
end

function heatmap_std_simulated_cross_rb_elevation(
    cross_rb::DataFrame,
    each_year_timing::Each_year_timing,
    n_x::Int,
    n_y::Int,
    start_year::Int,
    final_year::Int;
    japanese::Bool=false
    )
    
    if japanese == true 
        cl_t = "標準偏差 (m)"
        xl   = "河口からの距離 (km)"
        yl   = "川幅 (-)"
    else
        cl_t = "Standard deviation (m)"
        xl   = "Distance from the estuary (km)"
        yl   = "Width (-)"
    end
    
    figure_title = string(start_year, " - ", final_year)
    
    std_cross_rb_ele = zeros(Float64, n_x, n_y)

    calc_std_simulated_cross_rb_elevation!(
        std_cross_rb_ele,
        cross_rb,
        each_year_timing,
        start_year,
        final_year
    )
    
    X = 0:0.2:((n_x-1) * 0.2)
    Y = collect(Float64, 0:(n_y-1)) ./ (n_y-1)
    
    p = Plots.heatmap(
        X,
        Y,
        reverse!(std_cross_rb_ele'),
        xlabel=xl,
        xflip=true,
        ylabel=yl,
        colorbar_title=cl_t,
        colorbar_titlefontsize=14,
        colorbar_tickfontsize=11,
        clims=(0, 4.2),  
        xticks=[0, 20, 40, 60, 77.8],
        color=:amp,
        title=figure_title
    )
    
    
end

