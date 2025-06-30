const Task = require("../models/Task");

exports.createTask = async (req, res) => {
    try {
        const { title, description } = req.body;
        const newTask = await Task.create({
            userId: req.user.id,
            title,
            description
        });
        res.status(201).json(newTask);
    } catch (err) {
        res.status(500).json({ error: "Failed to create task" });
    }
};

exports.getTasks = async (req, res) => {
    try {
        const tasks = await Task.find({ userId: req.user.id });
        res.status(200).json(tasks);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch tasks" });
    }
};

exports.updateTask = async (req, res) => {
    try {
        const { id, title, description, status } = req.body;
        const taskId = id;
        const updatedTask = await Task.findOneAndUpdate(
            { _id: taskId, userId: req.user.id },
            { title, description, status },
            { new: true }
        );
        if (!updatedTask) {
            return res.status(404).json({ error: "Task not found or unauthorized" });
        }
        res.status(200).json(updatedTask);
    } catch (err) {
        res.status(500).json({ error: "Failed to update task" });
    }
};