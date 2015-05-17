define implementation_config::migrations($implementation_name, $app_name) {
  
  require implementation_config::config 
  
  $migrations_directory = "${::config::build_output_dir}/${::config::implementation_name}_config/${app_name}/migrations"

  file { "${temp_dir}/run-implementation-${app_name}-liquibase.sh" :
    ensure      => present,
    content     => template("implementation_config/run-implementation-${app_name}-liquibase.sh"),
    owner       => "${::config::bahmni_user}",
    group       => "${::config::bahmni_user}",
    mode        => 554
  }

  exec { "run_${app_name}_implementation_liquibase_migration" :
    command     => "${temp_dir}/run-implementation-${app_name}-liquibase.sh    ${::config::deployment_log_expression}",
    path        => "${config::os_path}",
    provider    => shell,
    cwd         => "${migrations_directory}",
    require     => File["${temp_dir}/run-implementation-${app_name}-liquibase.sh"],
    onlyif      => "test -f ${migrations_directory}/liquibase.xml"
  }
}