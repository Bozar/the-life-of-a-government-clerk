class_name HandleService


static func set_service_type(service_state: ServiceState, reset_type: bool,
        ref_RandomNumber: RandomNumber) -> void:

    var service_types: Array = []
    var new_service: int

    if reset_type:
        service_state.service_type = ServiceState.NO_SERVICE
        for i in service_state.service_record.keys():
            service_state.service_record[i] = false
        return

    for i in service_state.service_record.keys():
        if not service_state.service_record[i]:
            service_types.push_back(i)
    if service_types.is_empty():
        push_warning("No service type available.")
        service_state.service_type = ServiceState.NO_SERVICE
        return

    ArrayHelper.shuffle(service_types, ref_RandomNumber)
    new_service = service_types[0]
    service_state.service_type = new_service


static func use_service(service_state: ServiceState) -> void:
    service_state.service_record[service_state.service_type] = true
    service_state.service_type = ServiceState.NO_SERVICE
