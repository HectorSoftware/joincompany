enum DatabaseTables {
  none,
  users,
  forms,
  localities,
  responsibles,
  customFields,
  addresses,
  customers,
  tasks,
  customersUsers,
  customValues,
  customersAddresses,
}

const Map<DatabaseTables, String> databaseInstructions = {
  DatabaseTables.addresses:
    '''CREATE TABLE "users"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "supervisor_id" INTEGER,
    "name" TEXT,
    "code" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "mobile" TEXT,
    "title" TEXT,
    "password" TEXT,
    "details" TEXT,
    "profile" TEXT,
    "remember_token" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_users_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_users_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_users_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id")
    );
    CREATE INDEX "users.fk_users_users1_idx" ON "users" ("created_by_id");
    CREATE INDEX "users.fk_users_users2_idx" ON "users" ("updated_by_id");
    CREATE INDEX "users.fk_users_users3_idx" ON "users" ("deleted_by_id");
    ''',
  DatabaseTables.forms:
    '''CREATE TABLE "forms"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "name" TEXT,
    "with_checkinout" BOOL,
    "active" BOOL,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_forms_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_forms_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_forms_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id")
    );
    CREATE INDEX "forms.fk_forms_users1_idx" ON "forms" ("created_by_id");
    CREATE INDEX "forms.fk_forms_users2_idx" ON "forms" ("updated_by_id");
    CREATE INDEX "forms.fk_forms_users3_idx" ON "forms" ("deleted_by_id");
    ''',
  DatabaseTables.localities:
    '''CREATE TABLE "localities"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "collection" TEXT,
    "name" TEXT,
    "value" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_localities_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_localities_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_localities_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id")
    );
    CREATE INDEX "localities.fk_localities_users1_idx" ON "localities" ("created_by_id");
    CREATE INDEX "localities.fk_localities_users2_idx" ON "localities" ("updated_by_id");
    CREATE INDEX "localities.fk_localities_users3_idx" ON "localities" ("deleted_by_id");
    ''',
  DatabaseTables.responsibles:
    '''CREATE TABLE "responsibles"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "supervisor_id" INTEGER,
    "name" TEXT,
    "code" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "mobile" TEXT,
    "title" TEXT,
    "details" TEXT,
    "profile" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_responsibles_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_responsibles_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_responsibles_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_responsibles_responsibles1"
    FOREIGN KEY("supervisor_id")
    REFERENCES "responsibles"("id")
    );
    CREATE INDEX "responsibles.fk_responsibles_users1_idx" ON "responsibles" ("created_by_id");
    CREATE INDEX "responsibles.fk_responsibles_users2_idx" ON "responsibles" ("updated_by_id");
    CREATE INDEX "responsibles.fk_responsibles_users3_idx" ON "responsibles" ("deleted_by_id");
    CREATE INDEX "responsibles.fk_responsibles_responsibles1_idx" ON "responsibles" ("supervisor_id");
    ''',
  DatabaseTables.customFields:
    '''CREATE TABLE "custom_fields"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "section_id" INTEGER,
    "entity_type" TEXT,
    "entity_id" INTEGER,
    "type" TEXT,
    "name" TEXT,
    "code" TEXT,
    "subtitle" TEXT,
    "position" INTEGER,
    "field_default_value" TEXT,
    "field_type" TEXT,
    "field_placeholder" TEXT,
    "field_options" TEXT,
    "field_collection" TEXT,
    "field_required" BOOL,
    "field_width" INTEGER,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_custom_fields_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_custom_fields_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_custom_fields_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_custom_fields_custom_fields1"
    FOREIGN KEY("section_id")
    REFERENCES "custom_fields"("id")
    );
    CREATE INDEX "custom_fields.fk_custom_fields_users1_idx" ON "custom_fields" ("created_by_id");
    CREATE INDEX "custom_fields.fk_custom_fields_users2_idx" ON "custom_fields" ("updated_by_id");
    CREATE INDEX "custom_fields.fk_custom_fields_users3_idx" ON "custom_fields" ("deleted_by_id");
    CREATE INDEX "custom_fields.fk_custom_fields_custom_fields1_idx" ON "custom_fields" ("section_id");
    ''',
  DatabaseTables.addresses:
    '''CREATE TABLE "addresses"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "locality_id" INTEGER,
    "address" TEXT,
    "details" TEXT,
    "reference" TEXT,
    "latitude" DOUBLE,
    "longitude" DOUBLE,
    "google_place_id" TEXT,
    "country" TEXT,
    "state" TEXT,
    "city" TEXT,
    "contact_name" TEXT,
    "contact_phone" TEXT,
    "contact_mobile" TEXT,
    "contact_email" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_addresses_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_addresses_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_addresses_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_addresses_localities1"
    FOREIGN KEY("locality_id")
    REFERENCES "localities"("id")
    );
    CREATE INDEX "addresses.fk_addresses_users1_idx" ON "addresses" ("created_by_id");
    CREATE INDEX "addresses.fk_addresses_users2_idx" ON "addresses" ("updated_by_id");
    CREATE INDEX "addresses.fk_addresses_users3_idx" ON "addresses" ("deleted_by_id");
    CREATE INDEX "addresses.fk_addresses_localities1_idx" ON "addresses" ("locality_id");
    ''',
  DatabaseTables.customers:
    '''CREATE TABLE "customers"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "name" TEXT,
    "code" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "contact_name" TEXT,
    "details" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_customers_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_customers_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_customers_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id")
    );
    CREATE INDEX "customers.fk_customers_users1_idx" ON "customers" ("created_by_id");
    CREATE INDEX "customers.fk_customers_users2_idx" ON "customers" ("updated_by_id");
    CREATE INDEX "customers.fk_customers_users3_idx" ON "customers" ("deleted_by_id");
    ''',
  DatabaseTables.tasks:
    '''CREATE TABLE "tasks"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "created_by_id" INTEGER,
    "updated_by_id" INTEGER,
    "deleted_by_id" INTEGER,
    "form_id" INTEGER,
    "responsible_id" INTEGER,
    "customer_id" INTEGER,
    "address_id" INTEGER,
    "name" TEXT,
    "planning_date" DATETIME,
    "checkin_date" DATETIME,
    "checkin_latitude" DOUBLE,
    "checkin_longitude" DOUBLE,
    "checkin_distance" INTEGER,
    "checkout_date" DATETIME,
    "checkout_latitude" DOUBLE,
    "checkout_longitude" DOUBLE,
    "checkout_distance" INTEGER,
    "status" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_tasks_forms"
    FOREIGN KEY("form_id")
    REFERENCES "forms"("id"),
    CONSTRAINT "fk_tasks_responsibles1"
    FOREIGN KEY("responsible_id")
    REFERENCES "responsibles"("id"),
    CONSTRAINT "fk_tasks_customers1"
    FOREIGN KEY("customer_id")
    REFERENCES "customers"("id"),
    CONSTRAINT "fk_tasks_addresses1"
    FOREIGN KEY("address_id")
    REFERENCES "addresses"("id"),
    CONSTRAINT "fk_tasks_users1"
    FOREIGN KEY("created_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_tasks_users2"
    FOREIGN KEY("updated_by_id")
    REFERENCES "users"("id"),
    CONSTRAINT "fk_tasks_users3"
    FOREIGN KEY("deleted_by_id")
    REFERENCES "users"("id")
    );
    CREATE INDEX "tasks.fk_tasks_forms_idx" ON "tasks" ("form_id");
    CREATE INDEX "tasks.fk_tasks_responsibles1_idx" ON "tasks" ("responsible_id");
    CREATE INDEX "tasks.fk_tasks_customers1_idx" ON "tasks" ("customer_id");
    CREATE INDEX "tasks.fk_tasks_addresses1_idx" ON "tasks" ("address_id");
    CREATE INDEX "tasks.fk_tasks_users1_idx" ON "tasks" ("created_by_id");
    CREATE INDEX "tasks.fk_tasks_users2_idx" ON "tasks" ("updated_by_id");
    CREATE INDEX "tasks.fk_tasks_users3_idx" ON "tasks" ("deleted_by_id");
    INSERT INTO "tasks"("id","created_at","updated_at","deleted_at","created_by_id","updated_by_id","deleted_by_id","form_id","responsible_id","customer_id","address_id","name","planning_date","checkin_date","checkin_latitude","checkin_longitude","checkin_distance","checkout_date","checkout_latitude","checkout_longitude","checkout_distance","status","in_server","updated","deleted") VALUES(1, 'now()', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    INSERT INTO "tasks"("id","created_at","updated_at","deleted_at","created_by_id","updated_by_id","deleted_by_id","form_id","responsible_id","customer_id","address_id","name","planning_date","checkin_date","checkin_latitude","checkin_longitude","checkin_distance","checkout_date","checkout_latitude","checkout_longitude","checkout_distance","status","in_server","updated","deleted") VALUES(2, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    ''',
  DatabaseTables.customersUsers:
    '''CREATE TABLE "customers_users"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "customer_id" INTEGER,
    "user_id" INTEGER,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_customers_users_customers2"
    FOREIGN KEY("customer_id")
    REFERENCES "customers"("id"),
    CONSTRAINT "fk_customers_users_users2"
    FOREIGN KEY("user_id")
    REFERENCES "users"("id")
    );
    CREATE INDEX "customers_users.fk_customers_users_customers2_idx" ON "customers_users" ("customer_id");
    CREATE INDEX "customers_users.fk_customers_users_users2_idx" ON "customers_users" ("user_id");
    ''',
  DatabaseTables.customValues:
    '''CREATE TABLE "custom_values"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "form_id" INTEGER,
    "section_id" INTEGER,
    "field_id" INTEGER,
    "customizable_type" TEXT,
    "customizable_id" INTEGER,
    "value" TEXT,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_custom_values_forms1"
    FOREIGN KEY("form_id")
    REFERENCES "forms"("id"),
    CONSTRAINT "fk_custom_values_custom_fields1"
    FOREIGN KEY("section_id")
    REFERENCES "custom_fields"("id"),
    CONSTRAINT "fk_custom_values_custom_fields2"
    FOREIGN KEY("field_id")
    REFERENCES "custom_fields"("id")
    );
    CREATE INDEX "custom_values.fk_custom_values_forms1_idx" ON "custom_values" ("form_id");
    CREATE INDEX "custom_values.fk_custom_values_custom_fields1_idx" ON "custom_values" ("section_id");
    CREATE INDEX "custom_values.fk_custom_values_custom_fields2_idx" ON "custom_values" ("field_id");
    ''',
  DatabaseTables.customersAddresses:
    '''CREATE TABLE "customers_addresses"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "customer_id" INTEGER,
    "address_id" INTEGER,
    "approved" BOOL,
    "in_server" BOOL,
    "updated" BOOL,
    "deleted" BOOL,
    CONSTRAINT "fk_customers_addresses_customers1"
    FOREIGN KEY("customer_id")
    REFERENCES "customers"("id"),
    CONSTRAINT "fk_customers_addresses_addresses1"
    FOREIGN KEY("address_id")
    REFERENCES "addresses"("id")
    );
    CREATE INDEX "customers_addresses.fk_customers_addresses_addresses1_idx" ON "customers_addresses" ("address_id");
    CREATE INDEX "customers_addresses.fk_customers_addresses_customers1_idx" ON "customers_addresses" ("customer_id");
    ''',
};
