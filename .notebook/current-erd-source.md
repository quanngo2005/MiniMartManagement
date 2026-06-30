# Current ERD Source

## Context

Created `docs/ai-erd-drawing-guide.md` from the current EF Core model, DbContext configuration, and model snapshot.

## Source pointers

- Entity classes live in `backend/MiniMart/Models/`.
- Relationship configuration is in `backend/MiniMart/Data/MiniMartDbContext.cs`.
- Physical EF snapshot details are in `backend/MiniMart/Migrations/MiniMartDbContextModelSnapshot.cs`.

## Notes

- Current source has 22 modeled entities for ERD purposes.
- `Store` is mentioned in phase documentation, but there is no current `Store` model/DbSet in source.
- `Orders.ShiftId` exists as a nullable shadow FK in the model snapshot because `Shift.Orders` exists even though `Order.cs` does not declare `ShiftId`.
- `OrderDetail.AppliedPromotionId` is a nullable field, but no configured FK relationship to `Promotion` was found.
- `InventoryTransaction.ReferenceType`/`ReferenceId` are polymorphic reference fields, not hard database FKs.
