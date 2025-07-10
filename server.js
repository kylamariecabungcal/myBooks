const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); // ✅ ITO LANG ANG ISA

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb://127.0.0.1:27017/bookmanager', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
const db = mongoose.connection;
db.on('error', console.error.bind(console, '❌ MongoDB connection error:'));
db.once('open', () => console.log('✅ Connected to MongoDB'));

// Book schema & model
const bookSchema = new mongoose.Schema({
  title: String,
  author: String,
  year: String,
});
const Book = mongoose.model('Book', bookSchema);

// Routes
app.get('/api/books', async (req, res) => {
  try {
    const books = await Book.find();
    res.json(books);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch books.' });
  }
});

app.post('/api/books', async (req, res) => {
  try {
    const { title, author, year } = req.body;
    if (!title || !author || !year) {
      return res.status(400).json({ error: 'All fields are required.' });
    }
    const newBook = new Book({ title, author, year });
    await newBook.save();
    res.status(201).json(newBook);
  } catch (err) {
    res.status(500).json({ error: 'Failed to add book.' });
  }
});

app.delete('/api/books/:id', async (req, res) => {
  try {
    const deleted = await Book.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Book not found.' });
    }
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete book.' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`📚 Server running at http://localhost:${PORT}`);
});
