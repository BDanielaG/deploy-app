listView('Petclinic Jobs') {
    description('All CI/CD jobs related to the Petclinic project')
    filterBuildQueue()
    filterExecutors()
    jobs {
        regex('(?i).*petclinic.*')
    }
    columns {
        status()
        weather()
        name()
        lastSuccess()
        lastFailure()
        lastDuration()
        buildButton()
    }
}
listView('Test Jobs') {
    description('Initial test jobs for trying connections with different tools')
    filterBuildQueue()
    filterExecutors()
    jobs {
        regex('(?i).*first-freestyle|nexus-connection|sonarqube|test-trigger.*') 
    }
    columns {
        status()
        weather()
        name()
        lastSuccess()
        lastFailure()
        lastDuration()
        buildButton()
    }
}
listView('Seed job') {
    description('Job that creates jobs from DSL')
    filterBuildQueue()
    filterExecutors()
    jobs {
        regex('(?i).*seed.*')
    }
    columns {
        status()
        weather()
        name()
        lastSuccess()
        lastFailure()
        lastDuration()
        buildButton()
    }
}
