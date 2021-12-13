using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
//using UnityEngine.InputSystem;
using UnityEngine.XR;
using Dreamteck.Splines;

public class PuzzelPoint : MonoBehaviour
{
    //


    private SplineComputer spline;
    public SplinePoint[] points;

    //
    public Point[] pts;
    public Transform[] obstacles;
    public Point[] index;

    public Point startPt;
    public Point ExitePt;

    LineRenderer lr;
    private bool isOn;
    private List<Vector3> pointsOfLine = new List<Vector3>();
    private List<Point> PtOfLine = new List<Point>();
    public GameObject ob;
    // Get VR inputs
    private bool   hovered;
    InputDevice RightDevice;
    Get2DMovement mouse;
    //
    public Text text; // debuging
    private bool checkDir;
    private Vector3 currDir = Vector3.zero;
    private Vector3 end;

    public bool Solved;

   public UnityEvent IsSolved;

    private SmoothingPoints smt;
    private void Start()
    {

        //
        spline = gameObject.GetComponent<SplineComputer>();
        //points = new SplinePoint[segmentLength];
        //
        lr = this.GetComponent<LineRenderer>();
        foreach (Point p in pts)
        {
            if (p.startPt) startPt = p;
            break;
        }
        //
        List<InputDevice> D = new List<InputDevice>();

        InputDeviceCharacteristics RightCch = InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller;

        InputDevices.GetDevicesWithCharacteristics(RightCch, D);
        if (D.Count > 0)
        {
            RightDevice = D[0];
        }
        //smt = GetComponent<SmoothingPoints>();
        //
    }

    public Vector2 EndLinePos(Vector3 mousePos)
    {
        
        Vector2 end;
        if (isOn && (currDir == Vector3.up || currDir == Vector3.down))
        {
            end = new Vector2(PtOfLine[PtOfLine.Count - 1].transform.position.x, mousePos.y);
        }
        else if (isOn && (currDir == Vector3.right || currDir == Vector3.left))
        {
            end = new Vector2(mousePos.x, PtOfLine[PtOfLine.Count - 1].transform.position.y);
        }
        else { end = mousePos; }

        return end;
    }

    public bool GetButtonDown()
    {
        if (hovered)
        {
            
            RightDevice.TryGetFeatureValue(CommonUsages.trigger, out float TriggerValue);
            if (TriggerValue > 0.2f)
            {
                return true;

            }
            else return false;
           
        }
        else
            return false;
    }


    private void Update()
    {
        if (!Solved)
        {
            Vector2 mousePos;
            //
            if (mouse == null) mouse = FindObjectOfType<Get2DMovement>();
            //
            if (mouse != null)
            {
                mousePos = mouse.transform.position;

                end = EndLinePos(mousePos);

                if (GetButtonDown())
                {
                    //ob.transform.position = end;
                    if (Vector2.Distance(startPt.transform.position, end) < 0.17f)
                    {
                        AddFirstpt();

                    }
                }
                else
                {
                    clearAll(); text.text = "xxxaaa";
                }

                if (isOn)
                {
                    if (Vector2.Distance(end, ExitePt.transform.position) < 0.033f)
                    {
                        Win();
                    }
                    pointsOfLine.Add(end);

                }

                //checkPos();

                
                if (isOn)
                {
                    foreach (Point p in pts)
                    {
                        if (!PtOfLine.Contains(p) && Vector2.Distance(p.transform.position, end) < 0.05f)
                        {
                            AddPt(p);
                            break;
                        }
                    }
                    if (Vector2.Distance(end, PtOfLine[PtOfLine.Count - 1].transform.position) > 0.085f) GetDirection(mousePos);
                    checkPos(mousePos);

                    ob.transform.position = new Vector3(end.x, end.y, startPt.transform.position.z);
                }


                

            }
        }
        DrawLine();
       // DrawSplane();
        if (pointsOfLine.Count != 0 && !Solved) pointsOfLine.RemoveAt(pointsOfLine.Count - 1);

    }


    public void DrawSplane()
    {
        points = new SplinePoint[pointsOfLine.Count];
        for (int i = 0; i < points.Length; i++)
        {
            Vector3 x = new Vector3(pointsOfLine[i].x, pointsOfLine[i].y, startPt.transform.position.z);
            points[i] = new SplinePoint();
            points[i].position = x;
            points[i].normal = Vector3.up;
            points[i].size = 1f;
            points[i].color = Color.white;
        }
       

    }

    public void GetDirection(Vector3 mp)
    {
        float alpha;
        if (!checkDir)
        {

            alpha = -Vector2.SignedAngle(mp - PtOfLine[PtOfLine.Count - 1].transform.position, Vector3.right);

            //Debug.Log(Mathf.Cos(alpha * Mathf.Deg2Rad));
            if (Mathf.Cos(alpha * Mathf.Deg2Rad) > 0)
            {
                if (Mathf.Abs(alpha) < 45) CheckDir(Vector2.right);
                else if (alpha > 45) CheckDir(Vector2.up);
                else CheckDir(Vector2.down);
            }
            else
            {
                alpha = Vector2.SignedAngle(mp - PtOfLine[PtOfLine.Count - 1].transform.position, Vector3.left);

                if (Mathf.Abs(alpha) < 45) CheckDir(Vector2.left);
                else if (alpha > 45) CheckDir(Vector2.up);
                else CheckDir(Vector2.down);
            }
            // print("On");
            checkDir = true;
        }
    }

    public void CheckDir(Vector3 Dir)
    {
        if (Dir == Vector3.up && PtOfLine[PtOfLine.Count - 1].UpNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat"); text.text = "xxx";
        }
        else if (Dir == Vector3.up && PtOfLine[PtOfLine.Count - 1].UpNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        if (Dir == Vector3.right && PtOfLine[PtOfLine.Count - 1].rightNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat"); text.text = "xxx";
        }
        else if (Dir == Vector3.right && PtOfLine[PtOfLine.Count - 1].rightNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        if (Dir == Vector3.down && PtOfLine[PtOfLine.Count - 1].DownNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat"); text.text = "xxx";
        }
        else if (Dir == Vector3.down && PtOfLine[PtOfLine.Count - 1].DownNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        if (Dir == Vector3.left && PtOfLine[PtOfLine.Count - 1].LeftNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat"); text.text = "xxx";
        }
        else if (Dir == Vector3.left && PtOfLine[PtOfLine.Count - 1].LeftNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        //        Debug.Log(Dir);
        currDir = Dir;
    }

    public void checkPos(Vector3 mou)
    {
        if (Vector3.Distance(mou, end) > 1.5f) { clearAll(); text.text = "AAA"; }
    }



    public void DrawLine()
    {
        if (isOn ||Solved )
        {

            Vector3[] newPoints = Generate_Points(pointsOfLine.ToArray(),10, startPt.transform.position.z);
            lr.positionCount = newPoints.Length ;
            for (int i = 0; i < newPoints.Length; i++)
            {
                Vector3 x = new Vector3(newPoints[i].x, newPoints[i].y, startPt.transform.position.z);
                lr.SetPosition(i, x);
            }
        }
    }

    Vector3[] Generate_Points(Vector3[] keyPoints, int segments, float zValue)
    {
        Vector3[] Points = new Vector3[(keyPoints.Length - 1) * segments + keyPoints.Length];
        for (int i = 1; i < keyPoints.Length; i++)
        {
            Points[(i - 1) * segments + i - 1] = new Vector3(keyPoints[i - 1].x, keyPoints[i - 1].y, zValue);
            for (int j = 1; j <= segments; j++)
            {
                float x = keyPoints[i - 1].x;
                float y = keyPoints[i - 1].y;
                float z = zValue;
                float dx = (keyPoints[i].x - keyPoints[i - 1].x) / segments;
                float dy = (keyPoints[i].y - keyPoints[i - 1].y) / segments;
                Points[(i - 1) * segments + j + i - 1] = new Vector3(x + dx * j, y + dy * j, z);
            }
        }
        Points[(keyPoints.Length - 1) * segments + keyPoints.Length - 1] = new Vector3(keyPoints[keyPoints.Length - 1].x, keyPoints[keyPoints.Length - 1].y, zValue);
        return Points;
    }
    public void AddFirstpt()
    {
        if (PtOfLine.Count == 0)
        {
            ob.SetActive(true);
            text.text = "Hereeee";
            startPt.isSelected = true;
            PtOfLine.Add(startPt);
            isOn = true;
            Vector3 start = startPt.transform.position;
            pointsOfLine.Add(start);
        }
    }

    public void AddPt(Point p)
    {
        
        currDir = Vector3.zero;
        PtOfLine.Add(p);
        p.isSelected = true;
        pointsOfLine.Insert(pointsOfLine.Count - 1, p.transform.position);
        checkDir = false;
    }

    public void clearAll()
    {
        checkDir = false;
        isOn = false;
        pointsOfLine.Clear();
        foreach (Point p in PtOfLine) p.isSelected = false;
        PtOfLine.Clear();
        ob.transform.position = startPt.transform.position;
        lr.positionCount = 0;
        currDir = Vector3.zero;
        ob.SetActive(false);
    }

    public void Hovered()
    {
        hovered = true;
    }
    public void HoveredExit()
    {
        clearAll();
        text.text = "www";
        hovered = false;
    }

    public void test()
    {
        //text.text =" "+A;
        //A++;
    }

    public void checkWin()
    {
        if (PtOfLine.Count <= index.Length)
        {
            bool win = true;
            foreach(Point p in index)
                if (!p.isSelected)
                {
                    win = false;
                    break;
                }
            if (win) Win();
        }
    }

    private void Win()
    {
        bool win1=true;
        if (PtOfLine.Count >= index.Length)
        {
            foreach (Point p in index)
            {
                if (!p.isSelected) win1 = false;
            }

            if (win1)
            {
                Solved = true;
                IsSolved.Invoke();
            }
        }

        
    }
    
}
