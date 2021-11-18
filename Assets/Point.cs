using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Point : MonoBehaviour
{
    private List<Point> nighbers = new List<Point>();
    public bool isSelected;
    private PuzzelPoint puzzel;
    public bool startPt , ExitePt;
    private void Awake()
    {
        puzzel = FindObjectOfType<PuzzelPoint>();
    }

    private void Start()
    {
        nighbers.Add(GetTheUpPoint());
        nighbers.Add(GetTheRightPoint());
        nighbers.Add(GetTheDownPoint());
        nighbers.Add(GethTheLeftPoint());


    }



    public Point GetTheUpPoint()
    {
        Point UpNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.x == this.transform.position.x && p.transform.position.y > this.transform.position.y)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    UpNighber = p;

                }

            }
        }
        if (UpNighber != null)
            if (checkObstacle(UpNighber)) UpNighber = null;

        return UpNighber;
    }
    public Point GetTheDownPoint()
    {
        Point DownNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.x == this.transform.position.x && p.transform.position.y < this.transform.position.y)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    DownNighber = p;
                }
            }
        }
        if (DownNighber != null)
            if (checkObstacle(DownNighber)) DownNighber = null;

        return DownNighber;
    }
    public Point GetTheRightPoint()
    {
        Point rightNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.y == this.transform.position.y && p.transform.position.x > this.transform.position.x)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    rightNighber = p;
                }
            }
        }
        if (rightNighber != null)
            if (checkObstacle(rightNighber)) rightNighber = null;
        return rightNighber;
    }
    public Point GethTheLeftPoint()
    {
        Point leftNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.y == this.transform.position.y && p.transform.position.x < this.transform.position.x)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    leftNighber = p;
                }
            }
        }
        if (leftNighber != null)
            if (checkObstacle(leftNighber)) leftNighber = null;
        return leftNighber;
    }

    public bool checkObstacle(Point A)
    {
        bool existe = false;
        foreach (Transform t in puzzel.obstacles)
        {
            if (t.position.x == A.transform.position.x && t.position.x == this.transform.position.x)
            {
                float centre = (A.transform.position.y + this.transform.position.y) / 2;
                if (Mathf.Abs(centre - t.position.y) < Mathf.Abs(centre - this.transform.position.y)) existe = true;
            }
            if (t.position.y == A.transform.position.y && t.position.y == this.transform.position.y)
            {
                float centre = (A.transform.position.x + this.transform.position.x) / 2;
                if (Mathf.Abs(centre - t.position.x) < Mathf.Abs(centre - this.transform.position.x)) existe = true;
            }
        }

        return existe;
    }


    public Point UpNeighbor()
    {
        return nighbers[0];
    }
    public Point rightNeighbor()
    {
        return nighbers[1];
    }
    public Point DownNeighbor()
    {
        return nighbers[2];
    }
    public Point LeftNeighbor()
    {
        return nighbers[3];
    }
}
