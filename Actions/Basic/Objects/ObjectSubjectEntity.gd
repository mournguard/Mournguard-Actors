class_name ObjectSubjectEntity extends ActionObject

func retrieve():
	var subject = action.subject.retrieve()
	if not subject or not subject is Entity: return null
	else: return subject

func validate() -> bool:
	return action.subject.get_tags().has(Action.Tags.SUBJECT_IS_ENTITY)
