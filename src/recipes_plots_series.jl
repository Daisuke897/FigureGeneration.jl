Plots.RecipesBase.@recipe(
    function f(
        ::Type{Val{:distance_line}},
        x,                      # kilo meter
        y,
        z;
        x_max_km=77.8,
        x_vline=Vector{Real}(undef, 0)
        )

        seriestype := :line
        
        framestyle := :box
        grid := false

        primary := false
        xflip := true
        
        x_axis_vec = collect(range(0.0, stop = x_max_km, step = 20))
        push!(x_axis_vec, x_max_km)

        xlims --> (0.0, x_max_km)
        xticks --> x_axis_vec

        ylims --> (0.0, Inf)

        palette --> :default

        if length(x_vline) > 0

            Plots.RecipesBase.@series begin

                seriestype := :vline
                primary := false
                line := :black
                linestyle --> :dash
                label := ""
                linewidth := 1

                y := x_vline

            end

        end

        x := x
        y := y
        
    end
    
)

"""
    distance_line(x, y, z; <keyword arguments>)

横軸を河口からの距離 (km) とした線状のグラフを作成する。

# Arguments
- `x`: 河口からの距離 単位はキロメートル
- `japanese`: 初期値は`false` 日本語を出力するには`true`
- `x_vline`: 縦の破線を入れる河口からの距離の位置（キロメートル）の配列

"""
Plots.RecipesBase.@shorthands distance_line
