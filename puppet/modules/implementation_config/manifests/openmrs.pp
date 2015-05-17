  class implementation_config::openmrs inherits implementation_config::config {
    
  $openmrs_dir = "/home/${::config::bahmni_user}/.OpenMRS"
  $obscalculator_dir = "${::config::build_output_dir}/${::config::implementation_name}_config/openmrs/obscalculator"
  $patient_matching_algorithm_dir = "${::config::build_output_dir}/${::config::implementation_name}_config/openmrs/patientMatchingAlgorithm"
  $ordertemplates_dir = "${::config::build_output_dir}/${::config::implementation_name}_config/openmrs/ordertemplates"
  $encounter_modifier_scripts_dir = "${::config::build_output_dir}/${::config::implementation_name}_config/openmrs/encounterModifier"
  
  require implementation_config::setup

  file { "/tmp/mysql-connector-java-5.1.28.jar" :
      ensure  => "directory",
      source  => "puppet:///modules/implementation_config/mysql-connector-java-5.1.28.jar",
      owner   => "${::config::bahmni_user}",
      recurse => "true",
  }

  exec { "copyObsCalculatorToOpenMRSFolder" :
    command   => "cp -rf ${obscalculator_dir} ${openmrs_dir}",
    provider  => shell,
    path      => "${config::os_path}",
    onlyif    => "test -d ${obscalculator_dir}"
  }

  exec { "copyPatientMatchingAlgorithmToOpenMRSFolder" :
    command   => "cp -rf ${patient_matching_algorithm_dir} ${openmrs_dir}",
    provider  => shell,
    path      => "${config::os_path}",
    onlyif    => "test -d ${patient_matching_algorithm_dir}"
  }

  exec { "copyEncounterModifierScriptsToOpenMRSFolder" :
    command   => "cp -rf ${encounter_modifier_scripts_dir} ${openmrs_dir}",
    provider  => shell,
    path      => "${config::os_path}",
    onlyif    => "test -d ${encounter_modifier_scripts_dir}"
  }

  exec { "copyordertemplatesToOpenMRSFolder" :
    command   => "cp -rf ${ordertemplates_dir} ${openmrs_dir}",
    provider  => shell,
    path      => "${config::os_path}",
    onlyif    => "test -d ${ordertemplates_dir}"
  }

  exec { "changeOwnerAndPermissionForScriptFolders" :
    provider => "shell",
    command => "chown -R ${::config::bahmni_user}:${::config::bahmni_user} ${openmrs_dir}; chmod -R 775 ${openmrs_dir}",
    path => "${config::os_path}",
    require => [Exec["copyObsCalculatorToOpenMRSFolder"], Exec["copyPatientMatchingAlgorithmToOpenMRSFolder"], Exec["copyEncounterModifierScriptsToOpenMRSFolder"], Exec["copyordertemplatesToOpenMRSFolder"]]
  }

  implementation_config::migrations { "implementation_config_migrations_openmrs":
    implementation_name => "${::config::implementation_name}",
    app_name            => "openmrs"
  }

  exec { "copy_implementation_config" :
    command     => "rm -rf ${bahmniConfigDirectory}&& unzip -q -o ${implementation_config::setup::implementation_zip_file} 'openmrs/*' -d ${bahmniConfigDirectory}   ${::config::deployment_log_expression}",
    provider    => "shell",
    path        => "${config::os_path}"
  }

  exec { "set_owner_of_bahmni_config" :
    provider => "shell",
    command => "chown -R ${::config::bahmni_user}:${::config::bahmni_user} ${bahmniConfigDirectory}",
    path => "${config::os_path}",
    require => Exec["copy_implementation_config"]
  }

  exec { "set_permissions_of_bahmni_config" :
    provider => "shell",
    command => "chmod -R  777 ${bahmniConfigDirectory}",
    path => "${config::os_path}",
    require => Exec["copy_implementation_config"]
  }
}