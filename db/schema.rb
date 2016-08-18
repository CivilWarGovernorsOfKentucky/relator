# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160818133338) do

  create_table "annotations", force: true do |t|
    t.integer  "document_id"
    t.string   "verbation"
    t.integer  "user_id"
    t.integer  "entity_id"
    t.date     "hypothesis_date"
    t.string   "hypothesis_annotation_id"
    t.string   "hypothesis_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["document_id"], name: "index_annotations_on_document_id", using: :btree
  add_index "annotations", ["entity_id"], name: "index_annotations_on_entity_id", using: :btree
  add_index "annotations", ["user_id"], name: "index_annotations_on_user_id", using: :btree

  create_table "documents", force: true do |t|
    t.string   "cwgk_id"
    t.string   "xml_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", force: true do |t|
    t.string   "name"
    t.string   "entity_type"
    t.date     "birth_date"
    t.string   "birth_location"
    t.date     "death_date"
    t.string   "death_location"
    t.text     "biography"
    t.text     "bibliography"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities", ["user_id"], name: "index_entities_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "hypothesis_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end