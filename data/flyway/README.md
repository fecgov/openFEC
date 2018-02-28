1. Install `gradle` using `brew`.
2. `cd data/flyway`
3. Run `gradle clean`. This will clear all built artifacts.
4. Run `gradle distZip`. This will package a new distribution including flyway jars, migration scripts from the current branch, etc.
5. Update the name of the application, `flyway-independent-migration-kill-by-<date>`, in `manifest_headless_flyway.yml` with the right date. After ensuring that your cf environment is pointed to the right target, deploy the manifest using `cf push -f manifest_headless_flyway.yml`.
6. Check the result of the migration using `cf logs --recent flyway-independent-migration-kill-by-<date>`.
7. Delete the application using `cf delete flyway-independent-migration-kill-by-<date>`.
