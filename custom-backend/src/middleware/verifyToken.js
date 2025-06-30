const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
    const auth = req.header("Authorization");
    if (!auth)
        return res.status(401).send("Access denied!!!");

    const token = auth.split(" ")[1];
    if (!token)
        return res.status(401).send("Access denied!!!");

    try {
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified;
        next();
    } catch (err) {
        return res.status(400).send("Invalid token!!!");
    }
};

module.exports = verifyToken;