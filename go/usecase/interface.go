package usecase

type DatabasePlant interface {
	ListPlant() ([]Plant, error)
	SearchPlant([]int, []int) ([]Plant, error)
}

type DatabaseTag interface {
	ListTag() ([]Tag, error)
}

type DatabaseNear interface {
	ListNear(float64, float64, float64) ([]Near, error)
}

type DatabasePost interface {
	InsertPost(Post) error
}

var (
	DbPlant DatabasePlant
	DbTag   DatabaseTag
	DbNear  DatabaseNear
	DbPost  DatabasePost
)
