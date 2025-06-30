const express = require("express");
const router = express.Router();
const taskController = require("../controllers/task.controller");
const verifyToken = require("../middleware/verifyToken");

router.post("/create", verifyToken, taskController.createTask);

router.get("/all", verifyToken, taskController.getTasks);

router.put("/update", verifyToken, taskController.updateTask);

module.exports = router;