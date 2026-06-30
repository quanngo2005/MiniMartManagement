# Phase 4 Promotion Overlap Guard

## Scope

Phase 4 adds an application-level validation guard for promotions. It does not change the EF model or require a migration.

## Implementation

- `backend/MiniMart/Data/MiniMartDbContext.cs` overrides `SaveChanges` and `SaveChangesAsync`.
- Before saving, it validates changed `Promotion` rows and changed `PromotionProduct` links.
- The guard rejects active promotions when another active promotion already overlaps for the same product and `PromotionType`.
- Because this project currently exposes promotions through OData rather than a custom promotion controller, the validation lives in the DbContext save path so create/update writes are still covered.

## Overlap Rule

A conflict exists when:

- both promotions are active
- at least one product ID matches
- `Promotion.Type` matches
- existing `StartDate` is before the candidate `EndDate`
- existing `EndDate` is after the candidate `StartDate`

The guard throws `DomainException`, which `ExceptionMiddleware` turns into a JSON 400 response.

## Edge Cases Covered

- Creating or updating a `Promotion` with product links.
- Adding, updating, or deleting `PromotionProduct` links for an existing promotion.
- Multiple pending promotions in the same save operation overlapping each other.

## Gotchas

- `MiniMartDbContext.BuildPromotionGuardCandidates()` must return without querying `Promotions` when there are no changed `Promotion` or `PromotionProduct` entries. Otherwise unrelated saves, including failed login attempt tracking in `AuthService.LoginAsync()`, can fail if the live promotions schema is temporarily out of sync.
- On 2026-06-29, the local `MiniMartDB.dbo.Promotions` table had `MinOrderValue` while EF mapped `Promotion.DiscountAmount`. The repair was to rename `MinOrderValue` to `DiscountAmount`; the `AddDiscountAmmout` migration body is now idempotent for that drift.
