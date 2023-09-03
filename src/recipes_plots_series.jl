Plots.RecipesBase.@recipe(
    function f(
        ::Type{Val{:distance_line}},
        x,                      # meter
        y,
        z;
        japanese=false,
        x_vline=Vector{Real}(undef, 0)
        )

        seriestype := :line
        
        framestyle := :box
        grid := false

        primary := false
        xflip := true

        x_vec = x ./ 1000       # kilo meter
        
        max_x_km = round(maximum(x_vec), digits=1)
        x_axis_vec = collect(range(0, stop = max_x_km, step = 20))
        push!(x_axis_vec, max_x_km)

        xlims --> (0, max_x_km)
        xticks --> x_axis_vec

        ylims --> (0, Inf)

        palette --> :default

        xlabel --> if japanese == true
            "河口からの距離 (km)"
        else
            "Distance from the estuary (km)"
        end

        if length(x_vline) > 0

            Plots.RecipesBase.@series begin

                seriestype := :vline
                primary := false
                line := :black
                linestyle --> :dash
                label := ""
                linewidth := 1

                y := x_vline

                ()

            end

        end
        
        x := x_vec
        y := y

        ()
        
    end
    
)
Plots.RecipesBase.@shorthands distance_line
