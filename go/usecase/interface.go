package usecase

type DatabasePlant interface {
	ListPlant() ([]Plant, error)
	SearchPlant([]int, []int) ([]Plant, error)
}

type DatabaseTag interface {	
	ListTag() ([]Tag, error)
}

var (
	DbPlant DatabasePlant
	DbTag DatabaseTag
)
