package application

import jobsdomain "gamementor/internal/modules/jobs/domain"

type CreateJobInput struct {
	Type    jobsdomain.JobType    `json:"type"`
	Payload jobsdomain.JobPayload `json:"payload"`
}
