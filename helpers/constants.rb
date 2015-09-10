module Constants
  # new: newly created, draft.
  # auditing: speaker submits and waits for auditing.
  # approved: admin approves and arranges time for it
  # confirmed: speaker agrees the arrangement
  # finish: the speech is finished.
  # closed: close by the speaker or admin
  module SPEECH_STATUS
    NEW = "new"
    AUDITING = "auditing"
    APPROVED = "approved"
    CONFIRMED = "confirmed"
    FINISHED = "finished"
    CLOSED = "closed"
  end

  module SPEECH_CATEGORY
    WEEKLY = "weekly"
    MONTHLY = "monthly"
  end

  module USER_ROLE
    USER = "user"
    ADMIN = "admin"
  end

  module ATTENDANCE_ROLE
    SPEAKER = "speaker"
    AUDIENCE = "audience"
  end

end