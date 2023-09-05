#    Copyright (C) 2022  Daisuke Nakahara

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

module FigureGeneration

using Plots

function default_setting_plots()
    Plots.default(
        tickfontsize=18,
        legend_font_pointsize=13,
        titlefontsize=13,
        guidefontsize=18,
        legend_title_font_pointsize=13,
        dpi=300,
        grid=false,
        framestyle=:box,
        linewidth=2
    )
end

function default_setting_plots(fontfamily::String)

    default_setting_plots()
    
    Plots.default(
        fontfamily=fontfamily
    )
    
end

function check_dir_exist_if_no_mkdir(path_string::String)
    if isdir(path_string) == false
        mkdir(path_string)
    end
end

export default_setting_plots,
    check_dir_exist_if_no_mkdir,
    Plots

include("recipes_plots_series.jl")

include("read_df_river.jl")
using .Read_df_river
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

include("general_graph_module.jl")

include("rmse.jl")
using .RMSE
export
    make_RMSE_fluctuation_graph_each,
    make_RMSE_csv

include("riverbed_graph.jl")
using .RiverbedGraph
export
    comparison_final_average_riverbed,
    difference_final_average_riverbed,
    graph_comparison_difference_average_riverbed,    
    graph_cumulative_change_in_riverbed,
    graph_condition_change_in_riverbed,
    observed_riverbed_average_whole_each_year,
    observed_riverbed_average_section_each_year,
    graph_simulated_riverbed_fluctuation,
    graph_variation_per_year_simulated_riverbed_level,
    graph_variation_per_year_mearsured_riverbed_level,
    graph_variation_per_year_mearsured_riverbed_level_with_linear_model,
    graph_variation_per_year_simulated_riverbed_level_with_linear_model,    
    graph_observed_rb_level,
    graph_observed_rb_gradient,
    graph_transverse_distance,
    graph_elevation_gradient_width,    
    graph_measured_rb_crossing_1_year_en,
    graph_measured_rb_crossing_several_years,
    graph_simulated_rb_crossing,
    heatmap_measured_cross_rb_elevation,
    heatmap_std_measured_cross_rb_elevation,
    heatmap_std_simulated_cross_rb_elevation,    
    heatmap_diff_measured_cross_rb_elevation,
    heatmap_diff_per_year_measured_cross_rb_elevation,
    heatmap_diff_per_year_simulated_cross_rb_elevation,    
    heatmap_slope_by_model_measured_cross_rb_elevation,
    heatmap_slope_by_model_simulated_cross_rb_elevation    

include("particle_size.jl")
using .ParticleSize
export
    graph_ratio_simulated_particle_size_dist,
    graph_average_simulated_particle_size_dist,
    graph_average_simulated_particle_size_fluc,
    graph_cumulative_change_in_mean_diameter,
    graph_cumulative_ratio_in_mean_diameter,
    graph_cumulative_rate_in_mean_diameter,
    graph_cumulative_rate_variation_in_mean_diameter,
    graph_condition_change_in_mean_diameter,
    graph_condition_ratio_in_mean_diameter,
    graph_cumulative_condition_change_in_mean_diameter,
    graph_cumulative_condition_rate_in_mean_diameter,
    graph_measured_distribution

include("sediment_load.jl")
using .SedimentLoad
export
    make_graph_suspended_volume_flow_dist,
    make_graph_bedload_volume_flow_dist,
    make_graph_sediment_volume_flow_dist,
    make_graph_suspended_load_target_hour,
    make_graph_bedload_target_hour,
    make_graph_suspended_bedload_target_hour,
    make_graph_yearly_mean_suspended_load,
    make_graph_yearly_mean_bedload,
    make_graph_particle_yearly_mean_suspended,
    make_graph_particle_yearly_mean_bedload,
    make_graph_percentage_particle_yearly_mean_suspended,    
    make_graph_percentage_particle_yearly_mean_bedload,
    make_graph_amount_percentage_particle_yearly_mean_suspended,
    make_graph_amount_percentage_particle_yearly_mean_bedload,    
    make_graph_time_series_suspended_load,
    make_graph_time_series_bedload,
    make_graph_time_series_suspended_bedload,
    make_graph_time_series_variation_suspended_load,
    make_graph_time_series_variation_bedload,    
    make_graph_time_series_particle_suspended_load,
    make_graph_time_series_particle_bedload,
    make_graph_time_series_particle_suspended_bedload,    
    make_graph_time_series_percentage_particle_suspended_load,
    make_graph_time_series_percentage_particle_bedload,
    make_graph_time_series_amount_percentage_particle_suspended_load,    
    make_graph_time_series_amount_percentage_particle_bedload,    
    make_graph_condition_change_yearly_mean_suspended_load,
    make_graph_condition_rate_yearly_mean_suspended_load,    
    make_graph_condition_change_yearly_mean_bedload,
    make_graph_condition_rate_yearly_mean_bedload,
    make_graph_particle_sediment_volume_each_year,
    make_graph_yearly_mean_suspended_load_per_case,
    make_graph_yearly_mean_bed_load_per_case,
    make_figure_yearly_mean_particle_suspended_sediment_load_stacked,
    make_figure_yearly_mean_particle_bedload_sediment_load_stacked,
    make_suspended_sediment_per_year_csv,
    make_bedload_sediment_per_year_csv,
    make_suspended_sediment_mean_year_csv,
    make_bedload_sediment_mean_year_csv,
    # sediment_load_each_year.jl
    make_graph_particle_suspended_volume_each_year,
    make_graph_particle_suspended_volume_each_year_with_average_line,
    make_graph_condition_change_suspended_volume_each_year,
    make_graph_condition_change_suspended_volume_each_year_with_average_line,
    make_graph_particle_bedload_volume_each_year,
    make_graph_particle_bedload_volume_each_year_with_average_line,
    make_graph_condition_change_bedload_volume_each_year,
    make_graph_condition_change_bedload_volume_each_year_with_average_line

include("hydraulic_conditions.jl")
using .Hydraulic_conditions
export
    make_upstream_discharge_graph,
    make_downstream_water_level_graph,
    make_up_discharge_down_water_lev_graph

include("parameters.jl")
using .Parameters
export
    make_graph_energy_slope,
    make_graph_friction_velocity,
    make_graph_non_dimensional_shear_stress,
    make_graph_area,   
    make_graph_width,
    make_graph_velocity,
    make_graph_discharge,
    make_graph_water_level,
    make_graph_condition_change_water_level,
    make_graph_time_series_area,
    make_graph_time_series_width,
    make_graph_time_series_velocity,
    make_graph_time_series_discharge,
    make_graph_time_series_water_level,
    make_graph_time_series_water_level_with_measured,
    params

function __init__()

    default_setting_plots()

    nothing

end

end
