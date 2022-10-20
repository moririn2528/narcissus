package usecase

type DatabasePlant interface {
	ListPlant() ([]PlantHash, error)
	SearchPlant([]int, []int) ([]PlantHash, error)
	InsertPlant(plant Plant) (bool, int, error)
	SetTagsToPlant(int, []string) error
}

type DatabaseTag interface {
	ListTag() ([]Tag, error)
}

type DatabaseNear interface {
	ListNear(float64, float64, float64) ([]Near, error)
}

type DatabaseUploadPost interface {
	InsertUploadPost(UploadPost) error
}

var (
	DbPlant      DatabasePlant
	DbTag        DatabaseTag
	DbNear       DatabaseNear
	DbUploadPost DatabaseUploadPost
)
