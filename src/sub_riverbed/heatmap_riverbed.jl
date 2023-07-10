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
