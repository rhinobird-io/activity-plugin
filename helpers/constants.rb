module Constants
  # auditing: speaker submits and waits for auditing.
  # approved: admin approves and arranges time for it
  # confirmed: speaker agrees the arrangement
  # finish: the speech is finished.
  # closed: close by the speaker or admin
  module SPEECH_STATUS
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

  module EXCHANGE_STATUS
    NEW = 0
    SENT = 1
  end

  module COMMENT_STEP
    AUDITING = "auditing"
    REJECT = "reject"
    APPROVE = "approve"
    DISAGREE = "disagree"
    CLOSED = "closed"
  end

  module POINT
    MONTHLY = 200
    WEEKLY = 100
    MONTHLY_AUDIENCE = 20
    WEEKLY_AUDIENCE = 10
    COMMENT = 2
    LIKE = 2
  end

  module ATTACHMENT_TYPE
    NORMAL = "normal"
    VIDEO = "video"
  end
end
