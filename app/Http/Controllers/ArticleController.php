<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;

class ArticleController extends Controller
{

    public function index(Request $request)
    {
        $collection = array(["name" => "title 1", "content" => "content 1"],
                            ["name" => "title 2", "content" => "content 2"]);
        return response()->json($collection);
    }

    public function store(Request $request)
    {
        return response()->json(["status" => "success"], 201);
    }

}
